-- [[ SNACKS TERMINAL: The Terminal Command Center ]]
-- Domain: Workflow & External TUI Integration
--
-- PHILOSOPHY: Action-Driven JIT Infrastructure
-- We treat the terminal not as a background process, but as a modular tool.
-- Every external binary (Lazygit, Spotify, Aider) is lazy-loaded and
-- validated against mise shims before execution.
--
-- REFACTOR: Dropped akinsho/toggleterm.nvim in favor of snacks.terminal.
-- Snacks provides a lighter, native Neovim 0.10+ floating terminal
-- without the need for complex persistent proxy classes.

local M = {}
local utils = require 'core.utils'

M.setup = function()
  -- [[ THE TERMINAL FACTORY ]]
  -- Centralized logic for creating floating TUI instances.
  -- Replaces toggleterm's persistent class instantiation.
  local function create_tui(bin_name, desc, cmd_override)
    return function()
      local path = utils.mise_shim(bin_name)
      if not path then
        utils.soft_notify(desc .. ' missing. Install via: mise install ' .. bin_name, vim.log.levels.WARN)
        return
      end

      -- Use Snacks native terminal toggle.
      -- We pass the resolved shim path or the override command.
      require('snacks').terminal.toggle(cmd_override or path)
    end
  end

  -- [[ KEYMAP DEFINITIONS ]]

  -- 1. Standard Terminal Toggle
  vim.keymap.set({ 'n', 't' }, [[<C-\>]], function()
    require('snacks').terminal.toggle()
  end, { desc = 'Toggle Terminal (Snacks)' })

  -- 2. TUI Mappings (Workflow Hub)
  local tui_maps = {
    { '<leader>gg', 'lazygit', 'Git Client' },
    { '<leader>tp', 'btm', 'Process Monitor' },
    { '<leader>ts', 'spotify_player', 'Spotify' },
    { '<leader>ti', 'podman-tui', 'Container Infrastructure' },
  }

  for _, map in ipairs(tui_maps) do
    vim.keymap.set('n', map[1], create_tui(map[2], map[3]), { desc = 'TUI: ' .. map[3] })
  end

  -- 3. Dynamic Context Mappings (Aider & Glow)
  vim.keymap.set('n', '<leader>ta', function()
    local file = vim.fn.expand '%:p'
    local cmd = 'aider ' .. (file ~= '' and vim.fn.shellescape(file) or '')
    create_tui('aider', 'Aider AI', cmd)()
  end, { desc = 'TUI: Aider AI Chat' })

  vim.keymap.set('n', '<leader>vg', function()
    local file = vim.fn.expand '%:p'
    local bat = utils.mise_shim 'bat'
    local cmd = 'glow ' .. vim.fn.shellescape(file) .. (bat and (' | ' .. bat .. ' --paging=always') or '')
    create_tui('glow', 'Glow Markdown', cmd)()
  end, { desc = 'TUI: Markdown Preview' })

  -- Create a convenience alias for the Glow preview
  vim.keymap.set('n', '<leader>tm', '<leader>vg', { remap = true, silent = true })

  -- 4. Hardware/PlatformIO Domain
  local pio_tasks = {
    { '<leader>pb', 'pio run', 'Build Project' },
    { '<leader>pu', 'pio run -t upload', 'Upload Firmware' },
    { '<leader>pm', 'pio device monitor', 'Serial Monitor' },
    { '<leader>pc', 'pio project init --ide=vscode', 'Update [C]ompilation Database' },
  }

  for _, task in ipairs(pio_tasks) do
    vim.keymap.set('n', task[1], function()
      -- For PIO tasks, we execute the bash command.
      -- Replaces Toggleterm's close_on_exit = false logic. We append a read command to keep it open.
      require('snacks').terminal.toggle(task[2] .. "; read -p 'Press Enter to close...'")
    end, { desc = 'PIO: ' .. task[3] })
  end
end

return M
