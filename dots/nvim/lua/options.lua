local o = vim.opt

o.colorcolumn = "80"
o.termguicolors = true
o.showmode = false
o.cursorline = true

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

o.isfname:append { "(", ")" }
o.shortmess:append "sI"
o.fillchars = {
  -- stl = "─",
  -- stlnc = "─",
  eob = " ",
}

o.conceallevel = 2

-- dap icons
vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#f38ba8", })
vim.fn.sign_define("DapBreakpoint", {
  text = "󰑊",
  texthl = "DapBreakpoint",
})

vim.api.nvim_set_hl(0, "DapStopped", { fg = "#a6e3a1" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStopped" })
