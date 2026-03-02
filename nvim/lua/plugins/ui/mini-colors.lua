-- [[ CATPPUCCIN: Core Aesthetic Engine ]]
-- Domain: UI & Aesthetics

local M = {}
local utils = require 'core.utils'

local compiled_path = vim.fn.stdpath("cache") .. "/catppuccin"

local catppuccin_config = {
	compile_path = compiled_path,
	flavour = 'mocha',
	transparent_background = false,
	integrations = {
		cmp = false,
		blink_cmp = true,
		gitsigns = true,
		mini = { enabled = true },
		telescope = { enabled = false },
		treesitter = true,
	},
}

local function setup_and_compile()
	require('catppuccin').setup(catppuccin_config)
	vim.cmd("CatppuccinCompile")
end

local ok, err = pcall(function()
	require('mini.deps').add {
		source = 'catppuccin/nvim',
		name = 'catppuccin',
	}

	-- Skip setup when compiled cache exists — colorscheme entry point sources
	-- the compiled file directly, bypassing all integration setup code.
	if vim.fn.filereadable(compiled_path .. "/mocha") == 0 then
		setup_and_compile()
	end

	vim.cmd.colorscheme 'catppuccin-mocha'
end)

-- Re-compile whenever this file is saved
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*/plugins/ui/mini-colors.lua",
	callback = setup_and_compile,
})

if not ok then
	vim.cmd.colorscheme 'habamax'
	utils.soft_notify('Catppuccin failed to load. Falling back to native theme. Error: ' .. err, vim.log.levels.ERROR)
end

return M
