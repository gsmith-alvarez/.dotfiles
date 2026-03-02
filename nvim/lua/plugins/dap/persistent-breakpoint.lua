-- [[ PERSISTENT-BREAKPOINTS: Debug State Serialization ]]
-- Domain: Debugging & Project Continuity
--
-- ARCHITECTURE: Passive configuration. Placed in the UI layer.

local M = {}
local utils = require('core.utils')

M.setup = function()
	local ok, err = pcall(function()
		-- 1. THE BRIDGE: We MUST add the core DAP library to the runtime path
		-- before this plugin attempts to read breakpoints on BufReadPost.
		-- This invokes the lightweight bootstrap, NOT the heavy hardware adapters.
		require('plugins.dap.debug').bootstrap()

		local MiniDeps = require('mini.deps')
		MiniDeps.add('Weissle/persistent-breakpoints.nvim')

		require('persistent-breakpoints').setup({
			-- Native event handling to load signs
			load_breakpoints_event = { "BufReadPost" },

			-- XDG Compliance
			save_dir = vim.fn.stdpath("state") .. "/breakpoints/",
		})
	end)

	if not ok then
		utils.soft_notify('Persistent Breakpoints failed: ' .. err, vim.log.levels.ERROR)
	end
end

return M
