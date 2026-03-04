-- [[ UTILITIES & DATA PIPELINES ]]
-- Modularized logic for buffer manipulation, system interop, and data processing.
-- PRINCIPLE: Transform Neovim into a high-performance workbench for external CLI tools.

local M = {}

-- [[ View & External Tool Keymaps ]]
-- High-level entry points for the commands defined below.
vim.keymap.set('n', '<leader>vq', '<cmd>Jq<CR>', { desc = '[J]q Live Scratchpad' })
vim.keymap.set('n', '<leader>sR', '<cmd>Sd<CR>', { desc = '[S]earch & [R]eplace (Sd)' })
vim.keymap.set('n', '<leader>vx', '<cmd>Xh<CR>', { desc = '[X]h HTTP Client' })
vim.keymap.set('n', '<leader>vJ', '<cmd>Jless<CR>', { desc = '[J]less JSON Viewer' })

-- [[ Eradicate Search Highlights ]]
-- Uses <Esc> to clear the 'hlsearch' state, removing the yellow glare
-- from previous searches once you are done with them.
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR><Esc>', { desc = 'Clear search highlights' })

-- [[ Context Exfiltration: Path Yanking ]]
-- Pulls the current file context into the system clipboard ('+').

vim.keymap.set('n', '<leader>yp', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  -- NOTIFICATION: We use \n for a clean, two-line layout in the popup UI.
  vim.notify('Copied Absolute Path:\n' .. path, vim.log.levels.INFO)
end, { desc = '[Y]ank Absolute [P]ath' })

vim.keymap.set('n', '<leader>yr', function()
  local path = vim.fn.expand('%:~:.')
  vim.fn.setreg('+', path)
  vim.notify('Copied Relative Path:\n' .. path, vim.log.levels.INFO)
end, { desc = '[Y]ank [R]elative Path' })

-- [[ LSP Defibrillator ]]
-- A "hard reset" for code intelligence. Essential for clearing ghost diagnostics
-- or stuck RPC processes in large Go or C++ monorepos.
vim.keymap.set('n', '<leader>ur', '<cmd>LspRestart<CR>', { desc = '[U]tils [R]estart LSP' })

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

-- [[ BUFFER MANAGEMENT ARCHITECTURE ]]
-- Designed for "Zellij-style" navigation. 'H' and 'L' cycle through buffers
-- just like tab switching in a browser.

vim.keymap.set('n', '<leader>bd', function()
  -- NATIVE LEVERAGE: Use snacks.bufdelete to close the buffer without destroying window splits.
  local ok, snacks = pcall(require, 'snacks')
  if ok then
    snacks.bufdelete()
  else
    vim.cmd('bdelete')
  end
end, { desc = '[B]uffer [D]elete' })
