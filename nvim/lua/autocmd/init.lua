-- [[ AUTOCOMMANDS ORCHESTRATOR ]]
-- Architecture: Fault-Tolerant Module Loading
-- This file serves as the central dispatcher for all custom autocommands.

local utils = require('core.utils')

-- Define the domain-specific modules to be loaded.
local modules = {
  'autocmd.basic',    -- Core editor behaviors (yank, resize, etc)
  'autocmd.external', -- External tool integrations (mise, ouch, bigfile)
  'autocmd.jit',      -- Bootstrapping for heavy modules (Obsidian)
}

for _, module in ipairs(modules) do
  -- EXECUTION STRATEGY: The Protected Call (pcall)
  local ok, err = pcall(require, module)

  if not ok then
    -- ERROR CORRECTION: Log failure to state and notify UI.
    utils.soft_notify(string.format("CRITICAL: Failed to load %s\nError: %s", module, err), vim.log.levels.ERROR)
  end
end

-- [[ SELF-CORRECTING HOT RELOAD ]]
-- Detects when you save any file within the autocmd directory
-- and re-sources it instantly.
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*/lua/autocmd/*.lua',
  desc = 'Auto-reload autocmd modules on save',
  callback = function(event)
    -- 1. Safely extract the path (checking both match and file for robustness)
    local target_path = event.file or event.match
    local match = target_path:match('lua/(autocmd/.*)%.lua$')

    -- 2. The Barrier: If the regex fails, silently abort instead of crashing
    if not match then return end

    -- 3. Mutate
    local module_name = match:gsub('/', '.')

    -- 4. Purge cache and reload
    package.loaded[module_name] = nil

    local ok, err = pcall(require, module_name)
    if ok then
      vim.notify('🚀 Hot-Reloaded: ' .. module_name, vim.log.levels.DEBUG)
    else
      local utils = require('core.utils')
      utils.soft_notify('Reload Failed: ' .. err, vim.log.levels.ERROR)
    end
  end,
})

-- vim: ts=2 sts=2 sw=2 et
