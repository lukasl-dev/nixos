vim.lsp.buf.references = function()
  local builtin = require "telescope.builtin"
  builtin.lsp_references()
end

vim.lsp.buf.definition = function()
  local builtin = require "telescope.builtin"
  builtin.lsp_definitions()
end

vim.lsp.buf.implementation = function()
  local builtin = require "telescope.builtin"
  builtin.lsp_implementations()
end
