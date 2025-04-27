return {
  "saghen/blink.cmp",

  version = "1.*",
  build = "nix run .#build-plugin",

  dependencies = { "rafamadriz/friendly-snippets" },

  event = "BufWinEnter",

  ---@module "blink.cmp"
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = "default" },

    appearance = {
      nerd_font_variant = "mono"
    },

    completion = { documentation = { auto_show = false } },

    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    fuzzy = { implementation = "prefer_rust" }
    -- fuzzy.prebuilt_binaries.force_version
  },

  opts_extend = { "sources.default" }
}
