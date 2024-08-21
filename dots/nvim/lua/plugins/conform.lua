return {
  "stevearc/conform.nvim",

  event = "BufWritePre",

  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      go = { { "goimports", "gofumpt" }, { "goimports", "gofmt" } },
      markdown = { "mdformat" },
      python = { { "ruff_format" }, { "isort", "black" } },
      typescript = { { "biome" }, { "prettier", "eslint" } },
      typescriptreact = { { "biome" }, { "prettier", "eslint" } },
      javascript = { { "biome" }, { "prettier", "eslint" } },
      javascriptreact = { { "biome" }, { "prettier", "eslint" } },
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
