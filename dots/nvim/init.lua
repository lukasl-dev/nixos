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

require "options"

require("lazy").setup("plugins", require "lazy")

vim.schedule(function()
  vim.filetype.add(require "filetypes")
  require "mappings"
end)

vim.cmd.colorscheme "catppuccin"
