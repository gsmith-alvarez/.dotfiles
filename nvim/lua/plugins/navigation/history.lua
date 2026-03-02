-- [[ HISTORY & OMNISEARCH ]]
-- Domain: Temporal Navigation & Contextual Discovery
--
-- PHILOSOPHY: Recency-First discovery.
-- ARCHITECTURE: Snacks.picker + Ripgrep (Mise managed).
-- NOTE: Picker config and keymaps live in plugins/core/snacks.lua.
--       This module only ensures the dependency is registered.

local M = {}

M.setup = function()
	require('mini.deps').add('folke/snacks.nvim')
end

return M
