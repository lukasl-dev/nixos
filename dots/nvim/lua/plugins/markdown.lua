return {
  "MeanderingProgrammer/markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },

  ft = { "markdown" },

  opts = {
    latex = {
      -- Whether LaTeX should be rendered, mainly used for health check
      enabled = true,
      -- Executable used to convert latex formula to rendered unicode
      converter = "latex2text",
      -- Highlight for LaTeX blocks
      highlight = "RenderMarkdownMath",
      -- Amount of empty lines above LaTeX blocks
      top_pad = 0,
      -- Amount of empty lines below LaTeX blocks
      bottom_pad = 0,
    },
  },
}
