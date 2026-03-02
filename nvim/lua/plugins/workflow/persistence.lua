-- [[ MINI.SESSIONS: Session Management ]]
-- Domain: Workflow & Context Switching
--
-- PHILOSOPHY: Automatic State Recovery
-- Manually reopening files after a crash, restart, or branch switch
-- is a low-multiplier task. mini.sessions automates the "where was I?"
-- phase of development. Already bundled in mini.nvim — zero extra deps.

local M = {}
local utils = require('core.utils')

M.setup = function()
  local ok, err = pcall(function()
    require('mini.sessions').setup({
      autoread  = false, -- manual restore via keymap
      autowrite = true,  -- auto-save active session before quitting
      directory = vim.fn.stdpath('state') .. '/sessions',
      verbose   = { read = false, write = false, delete = false },
    })

    local ms = require('mini.sessions')

    -- Restore session for current working directory
    vim.keymap.set('n', '<leader>qs', function()
      ms.read()
    end, { desc = 'Restore Session (Current Dir)' })

    -- Interactive picker: select from all saved sessions
    vim.keymap.set('n', '<leader>ql', function()
      ms.select('read')
    end, { desc = 'Select & Restore Session' })

    -- Manually write the current session
    vim.keymap.set('n', '<leader>qw', function()
      ms.write(nil, { verbose = true })
    end, { desc = 'Save Session' })

    -- Disable autowrite for this session (close without saving)
    vim.keymap.set('n', '<leader>qd', function()
      ms.config.autowrite = false
      utils.soft_notify('Session autosave disabled', vim.log.levels.DEBUG)
    end, { desc = "Don't Save Current Session" })
  end)

  if not ok then
    utils.soft_notify('mini.sessions failed to load: ' .. err, vim.log.levels.ERROR)
  end
end

return M