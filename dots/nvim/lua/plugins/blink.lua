return {
  "saghen/blink.cmp",

  -- version = "1.*",
  build = "nix run --accept-flake-config .#build-plugin",

  dependencies = { "rafamadriz/friendly-snippets" },

  event = "BufWinEnter",

  --- @module "blink.cmp"
  --- @type blink.cmp.Config
  opts = {
    keymap = { preset = "default" },

    completion = { documentation = { auto_show = false } },

    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    fuzzy = { implementation = "prefer_rust" },

    signature = {
      enabled = true,
    },

    appearance = {
      nerd_font_variant = "mono",
    },
  },

  opts_extend = { "sources.default" },
}
