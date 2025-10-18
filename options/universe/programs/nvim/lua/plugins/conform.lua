return {
  "stevearc/conform.nvim",

  event = "BufWritePre",

  opts = {
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },

  config = function(opts)
    -- Load optional formatter definitions from runtime (lua/fmts/*.lua)
    local extra_formatters = {}
    local files = vim.api.nvim_get_runtime_file("lua/fmts/*.lua", true)
    for _, file in ipairs(files) do
      local fmt_name = file:match "([^/]+)%.%w+$"
      local ok, mod = pcall(require, "fmts." .. fmt_name)
      if ok and mod ~= nil then
        extra_formatters[fmt_name] = mod
      end
    end

    -- Merge any discovered formatter definitions into opts.formatters
    opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, extra_formatters)

    -- Rely on conform.nvim's built-in format_on_save; avoid custom autocmds
    require("conform").setup(opts)
  end,
}
