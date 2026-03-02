-- [[ INC-RENAME: Incremental LSP Renaming ]]
-- Domain: Text Manipulation & Refactoring
--
-- PHILOSOPHY: Precision JIT Loading
-- We abandon the broad 'CmdLineEnter' autocmd. The plugin's initialization
-- is tied directly to the LSP rename keybind and loads only if the buffer
-- can actually support the operation.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ The JIT Engine ]]
local function bootstrap_increname()
	if loaded then return true end

	-- 1. LSP Capability Guard
	-- Do not wake the plugin or download dependencies if the current buffer
	-- has no LSP attached, or if the attached server cannot perform renames.
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	local can_rename = false
	for _, client in ipairs(clients) do
		if client.server_capabilities.renameProvider then
			can_rename = true
			break
		end
	end

	if not can_rename then
		utils.soft_notify('LSP Error: No active language server supports renaming in this buffer.',
			vim.log.levels.WARN)
		return false
	end

	local ok, err = pcall(function()
		require('mini.deps').add('smjonas/inc-rename.nvim')
		require('inc_rename').setup({})
	end)

	if not ok then
		utils.soft_notify('Inc-Rename failed to initialize: ' .. err, vim.log.levels.ERROR)
		return false
	end

	loaded = true
	return true
end

-- [[ THE PROXY KEYMAP ]]
-- We replace the brittle `feedkeys` approach with Neovim's native `expr = true` evaluation.
-- This ensures the command line is populated synchronously and safely.
vim.keymap.set('n', '<leader>rn', function()
	if bootstrap_increname() then
		-- Return the command string directly to the command line
		return ":IncRename " .. vim.fn.expand('<cword>')
	end

	-- If the bootstrapper fails (e.g., no LSP attached), we return an empty
	-- string to prevent a Lua crash, keeping the failure silent and graceful.
	return ""
end, { expr = true, desc = 'LSP: [R]e[n]ame Symbol (JIT)' })

-- THE CONTRACT: Return the module to satisfy the Editing Orchestrator.
return M
