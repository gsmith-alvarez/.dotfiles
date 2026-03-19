-- [[ UI DOMAIN ORCHESTRATOR ]]
-- Location: lua/plugins/ui/init.lua
-- Domain: Aesthetics, Telemetry, and Visual Overlays
--
-- PHILOSOPHY: Strict Rendering Hierarchy
-- We abandon alphabetical loading in favor of a rigid, dependency-first
-- boot sequence. Foundational layers (colors and icons) must be locked in
-- memory before the telemetry engines (statusline/tabline) attempt to draw.

local M = {}
local utils = require 'core.utils'

-- [[ THE RENDERING PIPELINE ]]
-- Order is absolute. Do not alphabetize this list.

-- 1. THE FOUNDATION (Synchronous Blocking)
-- Must load first to prevent the "Flash of Unstyled Content" (FOUC)
-- and to polyfill icons for other plugins.
local sync_modules = {
  'ui.mini-colors',
  'ui.mini-starter',
}
for _, mod in ipairs(sync_modules) do
  local ok, mod_or_err = pcall(require, 'plugins.' .. mod)
  if ok and type(mod_or_err) == 'table' and type(mod_or_err.setup) == 'function' then
    local setup_ok, setup_err = pcall(mod_or_err.setup)
    if not setup_ok then
      utils.soft_notify(string.format('DOMAIN SETUP FAILURE: [%s]\n%s', 'plugins.' .. mod, setup_err), vim.log.levels.ERROR)
    end
  elseif not ok then
    local err = mod_or_err
    utils.soft_notify(string.format('UI-SYNC DOMAIN FAILURE: [%s]\n%s', mod, err), vim.log.levels.ERROR)
  end
end

-- 2. DEFERRED UI (Scheduled for Next Tick)
-- (Previously contained noice.nvim, now handled natively or via snacks)


-- 3. EVENT-BASED PLUGINS (JIT / Autocmd Triggers)
-- Requiring these is cheap; it only sets up the trigger (e.g., VimEnter, FileType)
-- that will perform the heavy lifting later.
local event_modules = {
  'ui.treesitter',
  'ui.trouble',
  'ui.render-markdown',
  'ui.mini-statusline',
  'ui.winbar',
  'ui.mini-clue',
}
for _, mod in ipairs(event_modules) do
  -- Resolve the full Lua namespace path relative to 'lua/' folder
  local module_path = 'plugins.' .. mod
  local ok, mod_or_err = pcall(require, module_path)
  if ok and type(mod_or_err) == 'table' and type(mod_or_err.setup) == 'function' then
    local setup_ok, setup_err = pcall(mod_or_err.setup)
    if not setup_ok then
      utils.soft_notify(string.format('DOMAIN SETUP FAILURE: [%s]\n%s', module_path, setup_err), vim.log.levels.ERROR)
    end
  elseif not ok then
    local err = mod_or_err
    -- Route fatal rendering failures to the diagnostic audit trail
    utils.soft_notify(string.format('UI-EVENT DOMAIN FAILURE: [%s]\n%s', module_path, err), vim.log.levels.ERROR)
  end
end

-- THE CONTRACT: Return the module to satisfy the Master Boot Sequence
return M
