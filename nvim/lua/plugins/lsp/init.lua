-- [[ LSP DOMAIN ORCHESTRATOR ]]
-- Location: lua/plugins/lsp/init.lua
-- Domain: Code Intelligence
--
-- PHILOSOPHY: Strict Order
-- Blink must load before native-lsp so capability broadcasting
-- happens before any server attaches.

local M = {}
local utils = require 'core.utils'

local modules = {
	'lsp.blink',      -- Completion engine (must be first)
	'lsp.native-lsp', -- Server configs + keymaps
}

for _, mod in ipairs(modules) do
	local module_path = 'plugins.' .. mod
	local ok, mod_or_err = pcall(require, module_path)
	if ok and type(mod_or_err) == 'table' and type(mod_or_err.setup) == 'function' then
		local setup_ok, setup_err = pcall(mod_or_err.setup)
		if not setup_ok then
			utils.soft_notify(string.format('LSP SETUP FAILURE: [%s]\n%s', module_path, setup_err), vim.log.levels.ERROR)
		end
	elseif not ok then
		utils.soft_notify(string.format('LSP DOMAIN FAILURE: [%s]\n%s', module_path, mod_or_err), vim.log.levels.ERROR)
	end
end

return M
