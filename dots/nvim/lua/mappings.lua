local map = vim.keymap.set

-- ====================================================================
-- lsp
-- ====================================================================

map("n", "gD", vim.lsp.buf.declaration, { silent = true })
map("n", "gd", vim.lsp.buf.definition, { silent = true })
map("n", "gi", vim.lsp.buf.implementation, { silent = true })
map("n", "gs", vim.lsp.buf.signature_help, { silent = true })

-- ====================================================================
-- diagnostic
-- ====================================================================

map("n", "[d", vim.diagnostic.goto_prev, { silent = true })
map("n", "]d", vim.diagnostic.goto_next, { silent = true })
map("n", "gef", vim.diagnostic.open_float, { silent = true })
map("n", "geq", vim.diagnostic.setqflist, { silent = true })

-- ====================================================================
-- lspsaga
-- ====================================================================

map("n", "<leader>lr", ":Lspsaga rename ++project<CR>", { silent = true })

-- ====================================================================
-- oil
-- ====================================================================

map("n", "-", "<CMD>Oil<CR>", { silent = true })

-- ====================================================================
-- telescope
-- ====================================================================

map("n", "<leader>ff", ":Telescope find_files<CR>", { silent = true })
map("n", "<leader>fw", ":Telescope live_grep<CR>", { silent = true })
map("n", "<leader>fb", ":Telescope buffers<CR>", { silent = true })
map("n", "gi", ":Telescope lsp_implementations<CR>", { silent = true })
map("n", "gd", ":Telescope lsp_definitions<CR>", { silent = true })
map("n", "gr", ":Telescope lsp_references<CR>", { silent = true })
map("n", "gl", ":Telescope diagnostics<CR>", { silent = true })

-- ====================================================================
-- supermaven
-- ====================================================================

map("i", "<C-j>", function()
  local suggestion = require "supermaven-nvim.completion_preview"
  if suggestion.has_suggestion() then
    suggestion.on_accept_suggestion()
  end
end, { silent = true })

-- ====================================================================
-- gitsigns
-- ====================================================================

map("n", "<leader>gD", ":Gitsigns toggle_deleted<CR>", { silent = true })

map("n", "<leader>hp", ":Gitsigns preview_hunk<CR>", { silent = true })
map("n", "<leader>hr", ":Gitsigns reset_hunk<CR>", { silent = true })
map("n", "<leader>hs", ":Gitsigns stage_hunk<CR>", { silent = true })
map("n", "<leader>hS", ":Gitsigns undo_stage_hunk<CR>", { silent = true })
map("n", "[h", ":Gitsigns prev_hunk<CR>", { silent = true })
map("n", "]h", ":Gitsigns next_hunk<CR>", { silent = true })

-- ====================================================================
-- diffview
-- ====================================================================

map("n", "<leader>gdo", ":DiffviewOpen<CR>", { silent = true })
map("n", "<leader>gdx", ":DiffviewClose<CR>", { silent = true })
map("n", "<leader>gdf", ":DiffviewFileHistory %<CR>", { silent = true })

-- ====================================================================
-- harpoon
-- ====================================================================

local harpoon = require "harpoon"

map("n", "<leader>a", function()
  harpoon:list():add()
end, { silent = true })
map("n", "<leader>o", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { silent = true })
map("n", "<leader>j1", function()
  harpoon:list():select(1)
end, { silent = true })
map("n", "<leader>j2", function()
  harpoon:list():select(2)
end, { silent = true })
map("n", "<leader>j3", function()
  harpoon:list():select(3)
end, { silent = true })
map("n", "<leader>j4", function()
  harpoon:list():select(4)
end, { silent = true })
map("n", "<leader>p", function()
  harpoon:list():prev()
end, { silent = true })
map("n", "<leader>n", function()
  harpoon:list():next()
end, { silent = true })
