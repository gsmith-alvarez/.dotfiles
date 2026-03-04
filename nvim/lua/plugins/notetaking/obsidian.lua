-- ============================================================================
-- MODULE: Obsidian.nvim Integration
-- CONTEXT: JIT loaded. Only executes when called by an autocmd or global stub.
-- ============================================================================

local M = {}

function M.setup()
  -- 1. Anti-Fragility & Graceful Degradation Check
  local has_rg = require('core.utils').mise_shim('rg')
  if not has_rg then
    vim.notify("Obsidian.nvim: 'rg' binary missing. Check mise configuration.", vim.log.levels.WARN)
    return
  end

  -- 2. Imperative Dependency Fetch via mini.deps
  require('mini.deps').add({
    source = 'epwalsh/obsidian.nvim',
    depends = { 'nvim-lua/plenary.nvim' } -- mini.pick is GONE.
  })

  -- 3. Execute the Setup Logic
  require("obsidian").setup({
    ui = { enable = false },

    -- MANDATORY: Must be the root to access both 201-University and 500-Resources
    workspaces = {
      {
        name = "vault",
        path = "~/Documents/Obsidian",
      },
    },

    -- Native mini.pick integration (mini.nvim is already in rtp)
    picker = { name = "mini.pick" },

    -- Matches your descriptive filename preference (No Zettelkasten IDs)
    note_id_func = function(title)
      if title ~= nil then return title end
      return tostring(os.time())
    end,

    -- Attachments relative to the course/folder
    attachments = { img_folder = "attachments" },

    -- ========================================================================
    -- AUTOMATED FRONTMATTER (MOC-Oriented)
    -- ========================================================================
    note_frontmatter_func = function(note)
      local out = {
        id = note.id,
        aliases = note.aliases,
        tags = note.tags,
        created = os.date("%Y-%m-%d %H:%M"),
      }

      if not out.tags then out.tags = {} end

      -- Auto-tag MOCs for pattern recognition
      if note.title and string.match(string.lower(note.title), "moc") then
        table.insert(out.tags, "MOC")
      end

      return out
    end,

    -- ========================================================================
    -- TEMPLATE CONFIGURATION
    -- ========================================================================
    templates = {
      -- Path is relative to the workspace path defined above
      folder = "500-Resources/Templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      -- Allow overriding existing variables in the note
      substitutions = {},
    },

    -- Buffer-local keymaps (only active inside a note)
    mappings = {
      -- 1. Navigation & MOC Workflow
      ["gf"] = {
        action = function() return require("obsidian").util.gf_passthrough() end,
        opts = { noremap = false, expr = true, buffer = true, desc = "Obsidian: Follow Link" },
      },
      ["<leader>nf"] = {
        action = function() return vim.cmd("ObsidianFollowLink tab") end,
        opts = { buffer = true, desc = "Obsidian: [F]ollow Link in Tab" },
      },
      ["<leader>nv"] = {
        action = function() vim.cmd("ObsidianFollowLink vsplit") end,
        opts = { buffer = true, desc = "Obsidian: Follow Link (V-Split)" },
      },
      ["<leader>nh"] = {
        action = function() vim.cmd("ObsidianFollowLink hsplit") end,
        opts = { buffer = true, desc = "Obsidian: Follow Link (H-Split)" },
      },
      ["<leader>nT"] = {
        action = function() vim.cmd("ObsidianTags") end,
        opts = { buffer = true, desc = "Obsidian: Search [T]ags" },
      },
      ["<leader>no"] = {
        -- Opens the current file in the Obsidian Desktop App
        action = function() vim.cmd("ObsidianOpen") end,
        opts = { buffer = true, desc = "Obsidian: [O]pen in GUI" },
      },
      ["<leader>nc"] = {
        action = function() vim.cmd("ObsidianTOC") end,
        opts = { buffer = true, desc = "Obsidian: [C]ontents (TOC)" },
      },


      -- 2. Note Creation & Templates
      ["<leader>nt"] = {
        action = function() vim.cmd("ObsidianTemplate") end,
        opts = { buffer = true, desc = "Obsidian: Insert [T]emplate" },
      },
      ["<leader>ne"] = {
        action = function() vim.cmd("ObsidianExtractNote") end,
        opts = { buffer = true, desc = "Obsidian: [E]xtract Selection to [N]ote" },
      },
      ["<leader>nl"] = {
        -- Prompts for a search query to link an existing note
        action = function() vim.cmd("ObsidianLink") end,
        opts = { buffer = true, desc = "Obsidian: [L]ink Existing [N]ote" },
      },
      ["<leader>nN"] = {
        -- Prompts for a title to create and link a NEW note
        action = function() vim.cmd("ObsidianLinkNew") end,
        opts = { buffer = true, desc = "Obsidian: Link [N]ew Note" },
      },

      -- 3. Media & Attachments
      ["<leader>np"] = {
        action = function() vim.cmd("ObsidianPasteImg") end,
        opts = { buffer = true, desc = "Obsidian: [P]aste Image from Clipboard" },
      },
    },


  })
end

return M
