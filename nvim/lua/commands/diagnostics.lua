-- [[ DIAGNOSTIC SUBSYSTEM ]]
-- Manages how Neovim communicates code intelligence errors to the user.

local M = {}

-- [[ Diagnostic Hover ]]
-- Triggers a floating window containing the full error message when the cursor idles.
local diag_group = vim.api.nvim_create_augroup("DiagnosticHover", { clear = true })

vim.api.nvim_create_autocmd("CursorHold", {
  group = diag_group,
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false, scope = "cursor" })
  end,
})

-- CRITICAL PERFORMANCE TUNING: `updatetime`
-- This controls the delay (in milliseconds) before the `CursorHold` event fires.
-- The Neovim default is an agonizing 4000ms. Lowering it to 500ms makes error
-- discovery feel instantaneous. (Note: This also controls how often Neovim
-- writes to the swap file, but 500ms is a highly stable modern standard).
vim.opt.updatetime = 500

-- [[ Diagnostic Discovery Toggles ]]
-- Diagnostics can create intense visual noise. These toggles allow you to
-- surgically mute the LSP when you are in the flow state, then turn it back
-- on for the error-correction phase.

vim.keymap.set('n', '<leader>tl', function()
  local is_enabled = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not is_enabled)
  vim.notify("Diagnostics: " .. (not is_enabled and "ON" or "OFF"), vim.log.levels.INFO)
end, { desc = '[T]oggle LSP [D]iagnostics' })

vim.keymap.set('n', '<leader>tu', function()
  local current = vim.diagnostic.config().underline
  vim.diagnostic.config({ underline = not current })
  vim.notify("Underlines: " .. (not current and "ON" or "OFF"), vim.log.levels.INFO)
end, { desc = '[T]oggle [U]nderlines' })

-- [[ Diagnostic Quickfix Routing ]]
vim.keymap.set('n', '<leader>q', function()
  -- If Trouble.nvim is loaded, delegate to its superior multi-file interface.
  -- Otherwise, fall back to dumping workspace diagnostics into the native quickfix list.
  local has_trouble, _ = pcall(require, 'trouble')
  if has_trouble then
    vim.cmd('Trouble diagnostics toggle')
  else
    vim.diagnostic.setqflist()
  end
end, { desc = '🗒️ Open diagnostic [Q]uickfix list' })

return M
