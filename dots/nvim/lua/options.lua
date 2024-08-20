local opt = vim.opt
local o = vim.opt

o.colorcolumn = "80"

o.number = true
o.relativenumber = true
o.numberwidth = 2
o.ruler = false

o.expandtab = true
o.shiftwidth = 2
o.smartindent = true
o.tabstop = 2
o.softtabstop = 2

o.signcolumn = "yes"
o.splitbelow = true
o.splitright = true
o.timeoutlen = 400
o.undofile = true

o.clipboard = "unnamedplus"
o.cursorline = true
o.cursorlineopt = "number"

opt.isfname:append { "(", ")" }
opt.fillchars = { eob = " " }
opt.shortmess:append "sI"

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
