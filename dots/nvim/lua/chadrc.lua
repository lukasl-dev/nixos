-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "catppuccin",

  tabufline = {
    enabled = true,
    order = { "treeOffset", "buffers", "tabs" },
    modules = {
      blank = function()
        return "%#Normal#" .. "%=" -- empty space
      end,
    },
  },

  statusline = {
    theme = "minimal",
    separator_style = "round",
    order = {
      "mode",
      "file",
      "git",
      "%=",
      "lsp_msg",
      "%=",
      "diagnostics",
      -- "lsp",
      "python_venv",
      "cwd",
    },
    modules = {
      python_venv = function()
        if vim.bo.filetype ~= "python" then
          return ""
        end

        local venv = os.getenv "VIRTUAL_ENV" or ""
        if venv == "" then
          return ""
        end

        local venv_name = string.match(venv, "[\\/]([^\\/]+)[\\/]?[^\\/]*$")
        if venv_name ~= "" then
          return "  " .. venv_name .. " "
        else
          return ""
        end
      end,
    },
  },

  -- hl_override = {
  --   Comment = { italic = true },
  --   ["@comment"] = { italic = true },
  -- },
}

return M
