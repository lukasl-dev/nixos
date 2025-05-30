local map = vim.keymap.set

-- ====================================================================
-- editing
-- ====================================================================
map("n", "<C-j>", "':m .+' .. v:count1 .. '<CR>=='", {
  expr = true,
  silent = true,
  desc = "Move line down by [count]",
})
map(
  "n",
  "<C-k>",
  "':m .-' .. (v:count1 + 1) .. '<CR>=='",
  { expr = true, silent = true, desc = "Move line up by [count]" }
)

-- ====================================================================
-- lsp
-- ====================================================================

map("n", "gD", vim.lsp.buf.declaration, { silent = true })
map("n", "gd", vim.lsp.buf.definition, { silent = true })
map("n", "gi", vim.lsp.buf.implementation, { silent = true })
map("n", "gs", vim.lsp.buf.signature_help, { silent = true })

-- ====================================================================
-- tabs
-- ====================================================================

map("n", "<leader>tn", ":tabnew<CR>", { silent = true })
map("n", "<leader>tq", ":tabclose<CR>", { silent = true })

-- ====================================================================
-- diagnostic
-- ====================================================================

map("n", "[d", function()
  vim.diagnostic.jump { count = -1 }
end, { silent = true })
map("n", "]d", function()
  vim.diagnostic.jump { count = 1 }
end, { silent = true })

map("n", "[D", function()
  vim.diagnostic.jump { count = -1, severity = vim.diagnostic.severity.ERROR }
end, { silent = true })
map("n", "]D", function()
  vim.diagnostic.jump { count = 1, severity = vim.diagnostic.severity.ERROR }
end, { silent = true })

map("n", "gef", vim.diagnostic.open_float, { silent = true })
map("n", "geq", vim.diagnostic.setqflist, { silent = true })

-- ====================================================================
-- dap
-- ====================================================================

map("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end)

map("n", "<leader>dc", function()
  require("dap").continue()
end)

map("n", "<leader>de", function()
  require("dapui").eval()
end)

map("n", "<leader>dr", ":DapToggleRepl<CR>")

map("n", "<leader>do", function()
  require("dap").step_over()
end)

map("n", "<leader>di", function()
  require("dap").step_into()
end)

map("n", "<leader>dO", function()
  require("dap").step_out()
end)

map("n", "<leader>dq", function()
  require("dap").terminate()
end)

map("n", "<leader>dQ", function()
  local dap = require "dap"
  dap.terminate()
  dap.clear_breakpoints()
end)

map("n", "<leader>du", function()
  require("dapui").toggle()
end)

-- ====================================================================
-- lspsaga
-- ====================================================================

map("n", "<leader>lr", ":Lspsaga rename ++project<CR>", { silent = true })
map("n", "<leader>la", ":Lspsaga code_action<CR>", { silent = true })

-- ====================================================================
-- oil
-- ====================================================================

map("n", "-", "<CMD>Oil<CR>", { silent = true })

-- ====================================================================
-- telescope
-- ====================================================================

map("n", "<leader>ff", ":Telescope find_files<CR>", { silent = true })
map(
  "n",
  "<leader>fh",
  ":Telescope find_files find_command=rg,--ignore,--hidden,--files<CR>",
  { silent = true }
)
map("n", "<leader>fw", ":Telescope live_grep<CR>", { silent = true })
map("n", "<leader>fb", ":Telescope buffers<CR>", { silent = true })
map("n", "gi", ":Telescope lsp_implementations<CR>", { silent = true })
map("n", "gd", ":Telescope lsp_definitions<CR>", { silent = true })
map("n", "gr", ":Telescope lsp_references<CR>", { silent = true })
map("n", "gl", ":Telescope diagnostics<CR>", { silent = true })

-- ====================================================================
-- copilot
-- ====================================================================

map("i", "<C-j>", function()
  local suggestion = require "copilot.suggestion"
  if suggestion.is_visible() then
    suggestion.accept_line()
  end
end, { silent = true })

-- ====================================================================
-- gitsigns
-- ====================================================================

local gitsigns = require "gitsigns"

map("n", "]h", function()
  if vim.wo.diff then
    vim.cmd.normal { "]c", bang = true }
  else
    gitsigns.nav_hunk "next"
  end
end)
map("n", "[h", function()
  if vim.wo.diff then
    vim.cmd.normal { "[c", bang = true }
  else
    gitsigns.nav_hunk "prev"
  end
end)

map("n", "<leader>gb", function()
  gitsigns.blame_line { full = true }
end)
map("n", "<leader>gD", gitsigns.toggle_deleted)

map("n", "<leader>hs", gitsigns.stage_hunk)
map("v", "<leader>hs", function()
  gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
end)
map("n", "<leader>hS", gitsigns.undo_stage_hunk)
map("v", "<leader>hr", function()
  gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
end)
map("n", "<leader>hp", gitsigns.preview_hunk)
map("n", "<leader>hd", gitsigns.diffthis)
map("n", "<leader>hD", function()
  gitsigns.diffthis "~"
end)

map("n", "<leader>bs", gitsigns.stage_buffer)
map("n", "<leader>br", gitsigns.reset_buffer)

-- ====================================================================
-- neogit
-- ====================================================================

map("n", "<leader>gg", ":Neogit<CR>", { silent = true })
map("n", "<leader>gd", ":Neogit diff<CR>", { silent = true })

-- ====================================================================
-- harpoon
-- ====================================================================

local harpoon = require "harpoon"

map("n", "<leader>a", function()
  harpoon:list():add()
end)
map("n", "<leader>o", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)
map("n", "<leader>p", function()
  harpoon:list():prev()
end)
map("n", "<leader>n", function()
  harpoon:list():next()
end)
for i = 1, 9 do
  map("n", string.format("<leader>%d", i), function()
    harpoon:list():select(i)
  end)
end
