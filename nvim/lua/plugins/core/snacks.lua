-- [[ SNACKS.NVIM: The Centralized Pillar ]]
-- Domain: Workflow, UI, Navigation, and Profiling
--
-- PHILOSOPHY: Single Source of Truth & Zero-Overhead Boot
-- We call setup exactly once. Snacks handles its own lazy-loading internally.
-- We only enable the profiler if the PROFILE=1 environment variable is set.

local M = {}
local utils = require 'core.utils'

M.setup = function()
  -- [[ THE BOOTSTRAPPER ]]
  -- Deferred to keep snacks.picker out of the startup hot path.
  -- Keymaps are registered immediately as closures; setup runs after first render.
  vim.schedule(function()
    local ok, err = pcall(function()
      require('snacks').setup {
      -- 1. UI: Immediate Message Interception (Lean)
      notifier = {
        enabled = true,
        timeout = 3000,
        top_down = false,
      },

      -- 2. PROFILING: Conditional overhead
      profiler = { enabled = vim.env.PROFILE ~= nil },

      -- 3. WORKFLOW: Definitions (Lazy-loaded on first call)
      terminal = {
        win = { border = 'curved', winblend = 3, keys = { q = 'hide' } },
      },

      -- 4. NAVIGATION: Definitions (Lazy-loaded on first call)
      picker = {
        enabled = true,
        ui_select = true,
        sources = {
          files = {
            hidden = true,
            ignored = true,
            exclude = { ".git", ".pio", "node_modules", "build" },
          },
        },
        win = {
          input = {
            keys = {
              ["<C-j>"] = { "list_down", mode = { "i", "n" } },
              ["<C-k>"] = { "list_up",   mode = { "i", "n" } },
            },
          },
        },
      },

      -- 5. EXPLICIT OPT-OUT: Save cycles by disabling unused modules
      dashboard = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      scope = { enabled = false },
      scroll = { enabled = false },
      words = { enabled = false },
    }
  end)

  if not ok then
    utils.soft_notify('Snacks.nvim failed: ' .. err, vim.log.levels.ERROR)
  end
  end)

  -- [[ ON-DEMAND KEYMAPS ]]
  -- These trigger the heavy code ONLY when you actually press the keys.
  local map = vim.keymap.set

  -- Profiler Keymaps (Only useful if PROFILE=1)
  if vim.env.PROFILE then
    map('n', '<leader>zp', function()
      require('snacks').profiler.scratch()
    end, { desc = 'Speedrun: Open Profiler', nowait = true })
    map('n', '<leader>zh', function()
      require('snacks').profiler.pick()
    end, { desc = 'Speedrun: Profile History', nowait = true })
  end

  map('n', '<leader>zl', function()
    require('snacks').toggle.profiler_highlights():toggle()
  end, { desc = '[S]peedrun: Toggle Line Highlights', nowait = true })

  -- Terminal & Search (Native Deferral)
  map({ 'n', 't' }, [[<C-\>]], function()
    require('snacks').terminal.toggle()
  end, { desc = 'Toggle Terminal' })
  map('n', '<leader><leader>', function()
    require('snacks').picker.buffers()
  end, { desc = 'Search: Active Buffers' })
  map('n', '<leader>so', function()
    require('snacks').picker.grep()
  end, { desc = 'Search Omni (Ripgrep)' })
  map('n', '<leader>fr', function()
    require('snacks').picker.recent()
  end, { desc = 'Find Recent Files' })
  map('n', '<leader>fc', function()
    require('snacks').picker.recent { filter = { cwd = true } }
  end, { desc = 'Find Contextual (CWD)' })
end

return M
