-- [[ UTILITIES & DATA PIPELINES ]]
-- Modularized logic for buffer manipulation, system interop, and data processing.
-- PRINCIPLE: Transform Neovim into a high-performance workbench for external CLI tools.
-- KEYMAPS: All keymaps live in lua/core/plugin-keymaps.lua.

local M = {}

-- External tool commands (invoked via keymaps in plugin-keymaps.lua)

-- [[ GoJQ: Native JSON Querying ]]
-- Pipeline: Current Buffer -> String -> GoJQ -> Quickfix List.
vim.api.nvim_create_user_command('Jq', function(opts)
  local utils = require('core.utils')
  local gojq = utils.mise_shim('gojq')

  if not gojq then
    utils.soft_notify('gojq is missing! Install via mise.', vim.log.levels.WARN)
    return
  end

  local query = opts.args == '' and '.' or opts.args
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  -- FIX: Corrected \n string splitting
  local input = table.concat(lines, '\n')

  local obj = vim.system({ gojq, query }, { stdin = input, text = true }):wait()

  if obj.code ~= 0 then
    utils.soft_notify('gojq error: ' .. (obj.stderr or 'Unknown'), vim.log.levels.ERROR)
    return
  end

  local qf_items = {}
  local output_lines = vim.split(obj.stdout, '\n')
  for i, line in ipairs(output_lines) do
    if line ~= "" then
      table.insert(qf_items, { text = line, lnum = i, filename = 'gojq-output' })
    end
  end

  vim.fn.setqflist(qf_items, 'r')
  local has_trouble, _ = pcall(require, 'trouble')
  if has_trouble then
    vim.cmd('Trouble quickfix toggle')
  else
    vim.cmd('copen')
  end
  vim.notify('JQ Query: ' .. query, vim.log.levels.DEBUG)
end, { nargs = '?', desc = 'Run gojq on current buffer' })

-- [[ Sd: Surgical Buffer Replace ]]
-- Uses 'sd' (modern sed) to perform regex transformations directly in the buffer.
vim.api.nvim_create_user_command('Sd', function(opts)
  local utils = require('core.utils')
  local sd = utils.mise_shim('sd')
  if not sd then return end

  if #opts.fargs < 2 then
    utils.soft_notify('Usage: :Sd "find this" "replace with"', vim.log.levels.WARN)
    return
  end

  local find, replace = opts.fargs[1], opts.fargs[2]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local input = table.concat(lines, '\n')

  local obj = vim.system({ sd, find, replace }, { stdin = input, text = true }):wait()
  if obj.code == 0 then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(obj.stdout, '\n'))
    vim.notify(string.format('sd: Replaced "%s" with "%s"', find, replace), vim.log.levels.INFO)
  else
    utils.soft_notify('sd error: ' .. (obj.stderr or 'Unknown'), vim.log.levels.ERROR)
  end
end, { nargs = '+', desc = 'Surgical replace via sd' })

-- [[ Xh: HTTP Playground ]]
-- Executes requests and uses a heuristic filetype detector to enable highlighting.
vim.api.nvim_create_user_command('Xh', function(opts)
  local utils = require('core.utils')
  local xh = utils.mise_shim('xh')
  if not xh then return end

  local cmd = { xh }
  for _, arg in ipairs(opts.fargs) do
    table.insert(cmd, arg)
  end

  vim.notify('Dispatching HTTP Request...', vim.log.levels.DEBUG)

  -- ASYNC HANDOFF: Pass a callback function instead of using :wait()
  vim.system(cmd, { text = true }, function(obj)
    -- Must schedule UI mutations back to the main Neovim thread
    vim.schedule(function()
      vim.cmd('vnew')
      local buf = vim.api.nvim_get_current_buf()
      vim.bo[buf].buftype, vim.bo[buf].bufhidden = 'nofile', 'wipe'

      local output = (obj.stdout and obj.stdout ~= "") and obj.stdout or obj.stderr or ""
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))

      -- AUTOMATED SYNTAX ACTIVATION
      if output ~= "" then
        if output:find('^{') or output:find('^%[') then
          vim.bo[buf].filetype = 'json'
        elseif output:find('<html') or output:find('<!DOCTYPE') then
          vim.bo[buf].filetype = 'html'
        end
      end
    end)
  end)
end, { nargs = '*', desc = 'Execute HTTP request via xh' })

-- [[ BUFFER MANAGEMENT ]]
-- Buffer deletion keymaps live in lua/core/plugin-keymaps.lua (<leader>b prefix).

-- [[ Better gx - Open URLs with System Default ]]
-- Replaces the default 'gx' behavior with a more robust implementation that handles various URL formats

vim.keymap.set("n", "gx", function()
  -- 1. First, check if the cursor is directly on a valid URL
  local cfile = vim.fn.expand("<cfile>")
  if cfile:match("^https?://") then
    return vim.ui.open(cfile)
  end

  -- 2. If not, parse the line to find the link nearest to the cursor
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- Current cursor column

  -- Iterate through all markdown links on the line
  for text, url in line:gmatch("%[([^%]]+)%]%((https?://[^%)]+)%)") do
    -- Find the starting position of this specific link string
    local start_idx, end_idx = line:find("%[" ..
    text:gsub("([^%w])", "%%%1") .. "%]%(" .. url:gsub("([^%w])", "%%%1") .. "%)")

    -- If the cursor is within the bounds of this specific Markdown link
    if start_idx and col >= start_idx and col <= end_idx then
      return vim.ui.open(url)
    end
  end

  -- 3. Fallback if no URL or Markdown link is found at cursor
  vim.ui.open(cfile)
end, { desc = "Smart open link under cursor" })
