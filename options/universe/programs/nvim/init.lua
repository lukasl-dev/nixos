vim.g.mapleader = " "

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    repo,
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("options")

require("lazy").setup("plugins", require("laziness"))

vim.schedule(function()
  vim.filetype.add(require("filetypes"))
  require("mappings")
end)

vim.schedule(function()
  local files = vim.api.nvim_get_runtime_file("lua/lsps/*.lua", true)
  for _, file in ipairs(files) do
    local lsp_name = file:match("([^/]+)%.%w+$")

    local module = require("lsps." .. lsp_name)
    if module ~= nil then
      if module.config ~= nil then
        vim.lsp.config(lsp_name, module.config)
      end
      vim.lsp.enable(lsp_name)
    end
  end
end)

vim.cmd.colorscheme("catppuccin")

-- Add the mason binary path to the PATH variable, so that plugins, such as
-- conform, can use the mason binaries.
local function configure_mason_path()
  local is_windows = vim.fn.has "win32" ~= 0
  local sep = is_windows and "\\" or "/"
  local delim = is_windows and ";" or ":"
  vim.env.PATH = table.concat({ vim.fn.stdpath "data", "mason", "bin" }, sep)
      .. delim
      .. vim.env.PATH
end
configure_mason_path()
