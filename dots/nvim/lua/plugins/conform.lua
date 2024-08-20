return {
  "stevearc/conform.nvim",

  event = "BufWritePre",

  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      go = { "gofmt" },
      markdown = { "mdformat" },
      python = { { "ruff_format" }, { "isort", "black" } },
      typescript = { { "biome" }, { "prettier", "eslint" } },
      typescriptreact = { { "biome" }, { "prettier", "eslint" } },
      javascript = { { "biome" }, { "prettier", "eslint" } },
      javascriptreact = { { "biome" }, { "prettier", "eslint" } },
      zig = { "zigfmt" },
    },

    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
}
