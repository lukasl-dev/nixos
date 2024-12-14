return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  -- event = {
  --   "BufReadPre" .. vim.fn.expand "~" .. "/notes/*.md",
  --   "BufNewFile" .. vim.fn.expand "~" .. "/notes/*.md",
  -- },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "notes",
        path = "~/notes/content",
      },
    },
    wiki_link_func = function(opts)
      return require("obsidian.util").wiki_link_path_prefix(opts)
    end,
  },
}
