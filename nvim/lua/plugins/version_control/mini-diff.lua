-- [[ MINI.DIFF + MINI.BRACKETED: Git Hunk Navigation ]]
-- Domain: Git
-- ARCHITECTURE: Deferred via MiniDeps.later — runs strictly after initial render.

local M = {}

M.setup = function()
	local MiniDeps = require('mini.deps')

	MiniDeps.later(function()
		-- 1. Bracketed Navigation (General)
		-- This provides native-feeling [b / ]b (buffers), [d / ]d (diagnostics), etc.
		require('mini.bracketed').setup()

		-- 2. Diff Management
		require('mini.diff').setup {
			view = {
				style = 'sign',
				signs = { add = '+', change = '~', delete = '_' }
			},
			-- Delay internal source processing to prioritize UI responsiveness
			delay = { text_change = 200 },
		}

		-- 3. Hunk Navigation & Interaction
		-- We override mini.bracketed defaults here to provide explicit descriptions
		local diff = require('mini.diff')

		vim.keymap.set('n', ']c', function() diff.goto_hunk('next') end, { desc = 'Next Git [C]hange' })
		vim.keymap.set('n', '[c', function() diff.goto_hunk('prev') end, { desc = 'Prev Git [C]hange' })

		-- Hunk Actions
		vim.keymap.set('n', '<leader>gs', function() diff.apply_hunk() end, { desc = 'Git: [S]tage Hunk' })
		vim.keymap.set('n', '<leader>gu', function() diff.reset_hunk() end, { desc = 'Git: [U]ndo Hunk' })

		-- Structural Views
		vim.keymap.set('n', '<leader>gD', function() diff.toggle_overlay(0) end,
			{ desc = 'Git: Toggle [D]iff Overlay' })
		vim.keymap.set('n', '<leader>gq', function() diff.export_to_qf('current') end,
			{ desc = 'Git: Export to [Q]uickfix' })
	end)
end

return M
