-- local lazy = {
--   {
--     dir = "lazy.nvim",
--     mod = "lazy",
--   },
--   {
--     dir = "indent-blankline.nvim",
--     mod = "ibl",
--   },
--   {
--     dir = "nvim-cmp",
--     mod = "cmp",
--   },
--   {
--     dir = "catppuccin",
--     mod = "catppuccin",
--   },
--   {
--     dir = "gitsigns.nvim",
--     mod = "gitsigns",
--   },
--   {
--     dir = "telescope.nvim",
--     mod = "telescope",
--   },
-- }
local rtp = vim.api.nvim_list_runtime_paths()
local library_paths = {
  vim.fn.expand "$VIMRUNTIME/lua",
  vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
}
for _, path in ipairs(rtp) do
  local lua_path = path .. "/lua"
  if vim.fn.isdirectory(lua_path) == 1 then
    table.insert(library_paths, lua_path)
  end
end

return {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = library_paths,
        -- library = {
        --   vim.fn.expand "$VIMRUNTIME/lua",
        --   vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
        --   vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
        --   vim.fn.stdpath "data" .. "/lazy/indent-blankline.nvim/lua/ibl",
        --   vim.fn.stdpath "data" .. "/lazy/nvim-cmp/lua/cmp",
        --   vim.fn.stdpath "data" .. "/lazy/catppuccin/lua/catppuccin",
        --   vim.fn.stdpath "data" .. "/lazy/gitsigns.nvim/lua/gitsigns",
        --   vim.fn.stdpath "data" .. "/lazy/telescope.nvim/lua/telescope",
        -- },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}
