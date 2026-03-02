-- [[ SHARED LIBRARIES ]]
-- Location: lua/core/libs.lua
-- Domain: Core Infrastructure
--
-- PHILOSOPHY: Pre-emptive Injection
-- Plenary is a dependency for almost every high-level plugin. By adding
-- it here, we ensure its modules (like 'plenary.async') are available
-- globally before any other plugin tries to require them.

local M = {}
local utils = require('core.utils')

-- We use a protected block to ensure a git failure doesn't halt the boot.
local ok, err = pcall(function()
  -- 1. nvim-lua/plenary.nvim: The Neovim Standard Library
  -- MiniDeps.add handles the runtimepath injection automatically.
  MiniDeps.add('nvim-lua/plenary.nvim')

  -- 2. mini.icons (Optional Library)
  -- If you eventually need global devicons, inject echasnovski/mini.icons here.
end)

if not ok then
  utils.soft_notify("CORE LIB FAILURE: Plenary failed to inject.\n" .. err, vim.log.levels.ERROR)
end

return M
