local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

local servers = {
  html = {},
  awk_ls = {},
  bashls = {},
  cmake = {},
  tailwindcss = {},
  zls = {},
  java_language_server = {},
  docker_compose_language_service = {},
  nil_ls = {},

  pyright = {
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          typeCheckingMode = "basic",
        },
      },
    },
  },

  gopls = {
    settings = {
      gopls = {
        completeUnimported = true,
        usePlaceholders = true,
        analyses = {
          unusedparams = true,
        },
      },
    },
  },

  tsserver = {
    init_options = {
      preferences = {
        importModuleSpecifierPreference = "non-relative",
        -- disableSuggestions = true,
      },
    },
    on_attach = function(client, bufnr)
      require("twoslash-queries").attach(client, bufnr)
    end,
  },

  powershell_es = {
    bundle_path = vim.fn.stdpath "data" .. "/mason/packages/powershell-editor-services",
    -- cmd = {
    --   "pwsh",
    --   "-NoLogo",
    --   "-NoProfile",
    --   "-Command",
    --   vim.fn.expand "~/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1",
    -- },
    settings = { powershell = { codeFormatting = { Preset = "OTBS" } } },
  },
}

for name, opts in pairs(servers) do
  local prev_on_attach = opts.on_attach
  opts.on_attach = function(client, bufnr)
    if prev_on_attach then
      prev_on_attach(client, bufnr)
    end
    on_attach(client, bufnr)
  end

  opts.on_init = on_init
  opts.capabilities = capabilities

  lspconfig[name].setup(opts)
end
