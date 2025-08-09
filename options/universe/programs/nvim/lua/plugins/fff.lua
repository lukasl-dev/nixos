return {
  "dmtrKovalenko/fff.nvim",
  build = "nix run .#release",

  event = "VeryLazy",

  opts = {
    -- UI dimensions and appearance
    width = 0.8, -- Window width as fraction of screen
    height = 0.8, -- Window height as fraction of screen
    prompt = " ", -- Input prompt symbol
    preview = {
      enabled = true,
      width = 0.5,
      max_lines = 100,
      max_size = 1024 * 1024, -- 1MB
    },
    title = "FFF Files", -- Window title
    max_results = 60, -- Maximum search results to display
    max_threads = 4, -- Maximum threads for fuzzy search

    keymaps = {
      close = "<Esc>",
      select = "<CR>",
      select_split = "<C-s>",
      select_vsplit = "<C-v>",
      select_tab = "<C-t>",
      -- Multiple bindings supported
      move_up = { "<Up>", "<C-p>" },
      move_down = { "<Down>", "<C-n>" },
      preview_scroll_up = "<C-u>",
      preview_scroll_down = "<C-d>",
    },

    -- Highlight groups
    hl = {
      border = "FloatBorder",
      normal = "Normal",
      cursor = "CursorLine",
      matched = "IncSearch",
      title = "Title",
      prompt = "Question",
      active_file = "Visual",
      frecency = "Number",
      debug = "Comment",
    },

    -- Debug options
    debug = {
      show_scores = false, -- Toggle with F2 or :FFFDebug
    },
  },
}
