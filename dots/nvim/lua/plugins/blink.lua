return {
  "saghen/blink.cmp",

  version = "1.*",
  build = "nix run --accept-flake-config .#build-plugin",

  dependencies = {
    "rafamadriz/friendly-snippets",
    "giuxtaposition/blink-cmp-copilot",
  },

  event = "BufWinEnter",

  --- @module "blink.cmp"
  --- @type blink.cmp.Config
  opts = {
    keymap = { preset = "default" },

    appearance = {
      nerd_font_variant = "mono",
    },

    completion = { documentation = { auto_show = false } },

    sources = {
      default = { "lsp", "path", "snippets", "buffer", "copilot" },

      providers = {
        copilot = {
          name = "copilot",
          module = "blink-cmp-copilot",
          score_offset = 100,
          async = true,
        },
      },
    },

    fuzzy = { implementation = "prefer_rust" },

    signature = { enabled = true },
  },

  opts_extend = { "sources.default" },
}
