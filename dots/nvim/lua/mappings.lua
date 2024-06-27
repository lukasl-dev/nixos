require "nvchad.mappings"

local map = vim.keymap.set
local unmap = vim.keymap.del

-- ====================================================================
-- general purpose
-- ====================================================================

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- allow to switch from terminal input mode to terminal normal mode
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "escape terminal mode" })

-- ====================================================================
-- nvim-tree
-- ====================================================================

unmap("n", "<leader>e")

-- ====================================================================
-- oil
-- ====================================================================

map("n", "-", "<CMD>Oil<CR>", { desc = "open parent directory" })

-- ====================================================================
-- telescope
-- ====================================================================

map("n", "gi", ":Telescope lsp_implementations<CR>", { silent = true })
map("n", "gd", ":Telescope lsp_definitions<CR>", { silent = true })
map("n", "gr", ":Telescope lsp_references<CR>", { silent = true })
map("n", "gl", ":Telescope diagnostics<CR>", { silent = true })

-- ====================================================================
-- copilot
-- ====================================================================

map("i", "<C-j>", "copilot#Accept('\\<CR>')", {
  expr = true,
  replace_keycodes = false,
  silent = true,
})

-- ====================================================================
-- trouble
-- ====================================================================

map("n", "<leader>xx", function()
  require("trouble").toggle()
end, { desc = "trouble toggle" })
map("n", "<leader>xw", function()
  require("trouble").toggle "workspace_diagnostics"
end, { desc = "trouble workspace diagnostics" })
map("n", "<leader>xd", function()
  require("trouble").toggle "document_diagnostics"
end, { desc = "trouble document diagnostics" })
map("n", "<leader>xq", function()
  require("trouble").toggle "quickfix"
end, { desc = "trouble quickfix" })
map("n", "<leader>xl", function()
  require("trouble").toggle "loclist"
end, { desc = "trouble loclist" })
map("n", "gR", function()
  require("trouble").toggle "lsp_references"
end, { desc = "trouble lsp references" })

-- ====================================================================
-- molten
-- ====================================================================

map("n", "<localleader>mi", function()
  local venv = os.getenv "VIRTUAL_ENV"
  local venv_name = "python3"

  if venv ~= nil then
    venv_name = string.match(venv, "[\\/]([^\\/]+)[\\/]?[^\\/]*$")
    local kernel_file = vim.fn.expand("~/AppData/Roaming/jupyter/kernels/" .. venv_name)

    if vim.loop.fs_stat(kernel_file) == nil then
      local nvim_dir = vim.fn.stdpath "config"
      vim.cmd(("python -m ipykernel install --user --name %s"):format(nvim_dir, venv_name))
    end
  end

  vim.cmd(("MoltenInit %s"):format(venv_name))
end, { desc = "initialize molten", silent = true })

map("n", "<localleader>e", ":MoltenEvaluateOperator<CR>", { silent = true, desc = "run operator selection" })
map("n", "<localleader>rl", ":MoltenEvaluateLine<CR>", { silent = true, desc = "evaluate line" })
map("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { silent = true, desc = "re-evaluate cell" })
map("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", { silent = true, desc = "evaluate visual selection" })
map("n", "<localleader>p", ":MoltenImagePopup<CR>", { silent = true, desc = "open image popup" })
map("n", "<localleader>i", ":MoltenInterrupt<CR>", { silent = true, desc = "interrupt cell" })
