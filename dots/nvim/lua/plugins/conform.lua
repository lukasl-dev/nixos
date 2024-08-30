return {
  "stevearc/conform.nvim",

  event = "BufWritePre",

  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      go = {
        { "goimports", "gofumpt" },
        { "goimports", "gofmt" },
        stop_after_first = true,
      },
      markdown = { "mdformat" },
      python = {
        { "ruff_format" },
        { "isort", "black" },
        stop_after_first = true,
      },
      typescript = {
        { "biome" },
        { "prettier", "eslint" },
        stop_after_first = true,
      },
      typescriptreact = {
        { "biome" },
        { "prettier", "eslint" },
        stop_after_first = true,
      },
      javascript = {
        { "biome" },
        { "prettier", "eslint" },
        stop_after_first = true,
      },
      javascriptreact = {
        { "biome" },
        { "prettier", "eslint" },
        stop_after_first = true,
      },
      zig = { "zigfmt" },
      nix = { "nixfmt" },
      just = { "just" },
    },

    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
}
