-- TODO: sign_define() is deprecated
vim.fn.sign_define(
  "DiagnosticSignError",
  { text = "", texthl = "DiagnosticSignError" }
)
vim.fn.sign_define(
  "DiagnosticSignWarn",
  { text = "", texthl = "DiagnosticSignWarn" }
)
vim.fn.sign_define(
  "DiagnosticSignInfo",
  { text = "", texthl = "DiagnosticSignInfo" }
)
vim.fn.sign_define(
  "DiagnosticSignHint",
  { text = "", texthl = "DiagnosticSignHint" }
)

--- @param bufnr integer
local function setup_codelense(bufnr)
  local function check_codelens_support()
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    for _, c in ipairs(clients) do
      if c.server_capabilities.codeLensProvider then
        return true
      end
    end
    return false
  end

  vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave', 'CursorHold', 'LspAttach', 'BufEnter' }, {
    buffer = bufnr,
    callback = function()
      if check_codelens_support() then
        vim.lsp.codelens.refresh({ bufnr = 0 })
      end
    end
  })
  vim.api.nvim_exec_autocmds('User', { pattern = 'LspAttached' })
end

--- @param client vim.lsp.Client
--- @param bufnr integer
local function on_attach(client, bufnr)
  setup_codelense(bufnr)
end

--- @param client vim.lsp.Client
local function on_init(client, _)
  if client:supports_method("textDocument/semanticTokens") then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

local function get_capabilities()
  return require("cmp_nvim_lsp").default_capabilities()

  -- local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- capabilities.textDocument.completion.completionItem = {
  --   documentationFormat = { "markdown", "plaintext" },
  --   snippetSupport = true,
  --   preselectSupport = true,
  --   insertReplaceSupport = true,
  --   labelDetailsSupport = true,
  --   deprecatedSupport = true,
  --   commitCharactersSupport = true,
  --   tagSupport = { valueSet = { 1 } },
  --   resolveSupport = {
  --     properties = {
  --       "documentation",
  --       "detail",
  --       "additionalTextEdits",
  --     },
  --   },
  -- }
  -- return capabilities
end

return {
  "neovim/nvim-lspconfig",

  event = "BufWinEnter",

  config = function()
    local lsp_files = vim.api.nvim_get_runtime_file("lua/lsps/*.lua", true)
    for _, file in ipairs(lsp_files) do
      local lsp_name = file:match "([^/]+)%.%w+$"

      local opts = require("lsps." .. lsp_name)
      opts.capabilities = get_capabilities()

      local overriden_on_attach = opts.on_attach
      opts.on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        if overriden_on_attach then
          overriden_on_attach(client, bufnr)
        end
      end

      local overriden_on_init = opts.on_init
      opts.on_init = function(client, result)
        on_init(client, result)
        if overriden_on_init then
          overriden_on_init(client, result)
        end
      end

      require("lspconfig")[lsp_name].setup(require("lsps." .. lsp_name))
    end
  end,
}
