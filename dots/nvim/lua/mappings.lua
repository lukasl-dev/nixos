require "nvchad.mappings"

local map = vim.keymap.set
local unmap = vim.keymap.del

unmap("n", "<leader>h")
unmap("n", "<leader>v")

-- ====================================================================
-- general purpose
-- ====================================================================

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- allow to switch from terminal input mode to terminal normal mode
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "escape terminal mode" })

-- ====================================================================
-- LSP
-- ====================================================================

map("n", "[d", vim.diagnostic.goto_prev, { desc = "previous diagnostic", silent = true })
map("n", "]d", vim.diagnostic.goto_next, { desc = "next diagnostic", silent = true })

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
-- supermaven
-- ====================================================================

map("i", "<C-j>", function()
  local suggestion = require("supermaven-nvim.completion_preview")
  if suggestion.has_suggestion() then
    suggestion.on_accept_suggestion()
  end
end, { silent = true, desc = "accept suggestion" })

-- ====================================================================
-- gitsigns
-- ====================================================================

map("n", "<leader>gD", ":Gitsigns toggle_deleted<CR>", { silent = true, desc = "toggle deleted" })

map("n", "<leader>hp", ":Gitsigns preview_hunk<CR>", { silent = true, desc = "preview hunk" })
map("n", "<leader>hr", ":Gitsigns reset_hunk<CR>", { silent = true, desc = "reset hunk" })
map("n", "<leader>hs", ":Gitsigns stage_hunk<CR>", { silent = true, desc = "stage hunk" })
map("n", "<leader>hS", ":Gitsigns undo_stage_hunk<CR>", { silent = true, desc = "undo stage hunk" })
map("n", "[h", ":Gitsigns prev_hunk<CR>", { silent = true, desc = "previous hunk" })
map("n", "]h", ":Gitsigns next_hunk<CR>", { silent = true, desc = "next hunk" })

-- ====================================================================
-- diffview
-- ====================================================================

map("n", "<leader>gdo", ":DiffviewOpen<CR>", { silent = true, desc = "open diffview" })
map("n", "<leader>gdx", ":DiffviewClose<CR>", { silent = true, desc = "close diffview" })
map("n", "<leader>gdf", ":DiffviewFileHistory %<CR>", { silent = true, desc = "open file history" })

-- ====================================================================
-- molten
-- ====================================================================

-- TODO: fix this for linux

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
