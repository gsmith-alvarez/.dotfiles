-- [[ CORE KEYMAPS DOMAIN ]]
-- Domain: Global Navigation & Window Management
--
-- PHILOSOPHY: Home-Row Efficiency & Layout Control
-- Contains ONLY foundational editor mappings. Domain-specific mappings
-- (LSP, Formatting, Mux) are strictly encapsulated in their respective modules.

local M = {}

-- [[ 1. TERMINAL INTEROP ]]

-- Escape Terminal Mode: <Esc><Esc>
-- The native <C-\><C-n> is non-intuitive. This double-escape allows for
-- a faster pivot back to Normal mode within the built-in terminal.
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })

-- [[ 2. WINDOW & SPLIT MANAGEMENT ]]
-- Using <leader>w as the prefix for all layout-destructive actions.

vim.keymap.set('n', '<leader>wv', '<cmd>vsplit<CR>', { desc = 'Window: [V]ertical Split' })
vim.keymap.set('n', '<leader>ws', '<cmd>split<CR>', { desc = 'Window: [S]plit Horizontal' })
vim.keymap.set('n', '<leader>wq', '<cmd>quit<CR>', { desc = 'Window: [Q]uit Current' })
vim.keymap.set('n', '<leader>wo', '<C-w>o', { desc = 'Window: [O]nly (Close others)' })
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = 'Window: [=] Equalize Sizes' })
vim.keymap.set('n', '<leader>wx', '<C-w>x', { desc = 'Window: [X] Swap Next' })

-- [[ 3. NAVIGATION: Smart Multi-Pane Movement ]]
-- Maps CTRL+hjkl to direct window movement.
-- NOTE: If using the 'smart-splits' plugin, these will be overridden to
-- allow seamless jumping between Neovim and Zellij/Tmux panes.

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus Left' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus Right' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus Down' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus Up' })

-- [[ 4. TEXT EDITING: Word Wrap Logic ]]
-- Remap for dealing with word wrap (move visually by default).
-- If a line wraps, 'j' and 'k' will move to the next visible line
-- rather than the next actual line number, unless a count is provided (e.g. 5j).
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ 5. SYMBOL REFACTORING ]]
-- Leverages IncRename (if installed) for real-time symbol renaming.
vim.keymap.set('n', '<leader>rn', function()
  require('inc_rename').rename()
end, { desc = '[R]e[n]ame Symbol (JIT)' })

-- [[ 6. BUFFER NAVIGATION ]]
vim.keymap.set('n', 'H', '<cmd>bprevious<CR>', { desc = 'Go to Previous Buffer' })
vim.keymap.set('n', 'L', '<cmd>bnext<CR>', { desc = 'Go to Next Buffer' })

return M
