-- [[ MINI.FILES: File Explorer ]]
-- Domain: Navigation
-- Deferred via MiniDeps.later — runs after the initial render.

local M = {}

M.setup = function()
	require('mini.deps').later(function()
		require('mini.files').setup {
			windows = { preview = true, width_focus = 30 },
		}

		local show_dotfiles = true
		local filter_show = function(_) return true end
		local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, '.') end

		local toggle_dotfiles = function()
			show_dotfiles = not show_dotfiles
			local new_filter = show_dotfiles and filter_show or filter_hide
			require('mini.files').refresh({ content = { filter = new_filter } })
		end

		local map_split = function(buf_id, lhs, direction)
			local rhs = function()
				local mf = require('mini.files')
				local cur_target = mf.get_explorer_state().target_window
				local new_target = vim.api.nvim_win_call(cur_target, function()
					vim.cmd(direction .. ' split')
					return vim.api.nvim_get_current_win()
				end)
				mf.set_target_window(new_target)
				mf.go_in({ close_on_file = true })
			end
			vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = 'Split ' .. direction })
		end

		vim.api.nvim_create_autocmd('User', {
			pattern = 'MiniFilesBufferCreate',
			callback = function(args)
				local buf_id = args.data.buf_id
				map_split(buf_id, '<C-s>', 'belowright horizontal')
				map_split(buf_id, '<C-v>', 'belowright vertical')
				vim.keymap.set('n', 'g.', toggle_dotfiles, { buffer = buf_id, desc = 'Toggle Hidden Files' })
			end,
		})

		vim.keymap.set('n', '<leader>fe', function()
			require('mini.files').open(vim.fn.getcwd())
		end, { desc = 'Open [F]ile [E]xplorer (Root)' })
		vim.keymap.set('n', '-', function()
			require('mini.files').open(vim.api.nvim_buf_get_name(0))
		end, { desc = 'Open Explorer (Current Dir)' })
	end)
end

return M
