-- [[ GUESS-INDENT: Automatic Indentation Detection ]]
-- Domain: Text Manipulation & Formatting
--
-- PHILOSOPHY: Defer to Buffer Read
-- Indentation detection is critical but useless during the initial
-- boot phase. We use a self-destructing event listener to load it.

local M = {}
local utils = require('core.utils')

local group = vim.api.nvim_create_augroup('Editing_GuessIndent', { clear = true })

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  group = group,
  callback = function(args)
    local ok, err = pcall(function()
      require('mini.deps').add('NMAC427/guess-indent.nvim')
      require('guess-indent').setup({})

      -- Force the engine to evaluate the file that triggered this bootstrapper.
      -- We schedule this for the next tick to ensure the buffer is fully
      -- loaded into memory before the AST/Regex engine tries to parse it.
      vim.schedule(function()
        pcall(require('guess-indent').set_from_buffer, args.buf)
      end)
    end)

    if not ok then
      utils.soft_notify('Guess-Indent failed to initialize: ' .. err, vim.log.levels.ERROR)
    end

    -- 2. The Native Self-Destruct
    -- Returning true signals the Neovim event loop to delete this autocommand.
    -- It will never fire again for the duration of the session.
    return true
  end,
})

-- THE CONTRACT: Return the module to satisfy the Editing Orchestrator.
return M
