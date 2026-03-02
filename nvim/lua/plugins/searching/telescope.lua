-- [[ SEARCH KEYMAPS: Powered by snacks.picker ]]
-- Domain: Search & Discovery
-- All keymaps are direct closures — no bootstrap, no lazy loading overhead.

local search_keys = {
	{ '<leader>ff', function() require('snacks').picker.files() end,                                          'Find Files' },
	{ '<leader>cd', function() require('snacks').picker.zoxide() end,                                         'Zoxide Directory' },
	{ '<leader>sg', function() require('snacks').picker.grep() end,                                           'Grep Project' },
	{ '<leader>sw', function() require('snacks').picker.grep_word() end,                                      'Grep Word Under Cursor' },
	{ '<leader>sd', function() require('snacks').picker.diagnostics() end,                                    'Search Diagnostics' },
	{ '<leader>sr', function() require('snacks').picker.resume() end,                                         'Resume Last Search' },
	{ '<leader>sh', function() require('snacks').picker.help() end,                                           'Search Help' },
	{ '<leader>sk', function() require('snacks').picker.keymaps() end,                                        'Search Keymaps' },
	{ '<leader>sn', function() require('snacks').picker.files({ cwd = vim.fn.stdpath('config') }) end,        'Search Neovim files' },
}

for _, k in ipairs(search_keys) do
	vim.keymap.set('n', k[1], k[2], { desc = 'Search: ' .. k[3] })
end

return {}

