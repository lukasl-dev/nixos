return {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          vim.fn.expand "$VIMRUNTIME/lua",
          vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
          vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
          vim.fn.stdpath "data" .. "/lazy/indent-blankline.nvim/lua/ibl",
          vim.fn.stdpath "data" .. "/lazy/nvim-cmp/lua/cmp",
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}
