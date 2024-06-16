require "nvchad.options"

local nvim_dir = vim.fn.stdpath "config"

local o = vim.o
local g = vim.g

-- o.cursorlineopt = "both" -- to enable cursorline!

-- Python provider
g.python3_host_prog = vim.fn.expand(nvim_dir .. "/python/.venv/Scripts/python")
g.loaded_python3_provider = 1

-- Show a colum at colum 80
o.colorcolumn = "80"

-- Relative line numbers
o.number = true
o.relativenumber = true

-- Use system clipboard
o.clipboard = "unnamedplus"

-- Support "(" and ")" in filenames
vim.opt.isfname:append { "(", ")" }

-- Enable providers
-- https://github.com/NvChad/NvChad/issues/1417#issuecomment-1203490842
local enable_providers = {
  "python3_provider",
}
for _, plugin in pairs(enable_providers) do
  vim.g["loaded_" .. plugin] = nil
  vim.cmd("runtime " .. plugin)
end
