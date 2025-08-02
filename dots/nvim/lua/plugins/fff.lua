return {
  "fvrings/fff.nvim",
  build = "nix run .#release",

  -- event = "VeryLazy",

  opts = {
    width = 0.8, -- Window width as fraction of screen
    height = 0.8, -- Window height as fraction of screen
    preview_width = 0.5, -- Preview pane width as fraction of picker
    prompt = " ", -- Input prompt symbol
    title = "FFF Files", -- Window title
    max_results = 60, -- Maximum search results to display
    max_threads = 4, -- Maximum threads for fuzzy search

    keymaps = {
      close = "<Esc>",
      select = "<C-y>",
      select_split = "<C-s>",
      select_vsplit = "<C-v>",
      select_tab = "<C-t>",
      move_up = { "<Up>", "<C-p>" },
      move_down = { "<Down>", "<C-n>" },
      preview_scroll_up = "<C-u>",
      preview_scroll_down = "<C-d>",
    },

    -- hl = {
    --   border = "FloatBorder",
    --   normal = "Normal",
    --   cursor = "CursorLine",
    --   matched = "IncSearch",
    --   title = "Title",
    --   prompt = "Question",
    --   active_file = "Visual",
    --   frecency = "Number",
    --   debug = "Comment",
    -- },

    -- debug = {
    --   show_scores = true, -- We hope for your collaboration
    -- },
  },
}
