return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nushell/tree-sitter-nu" },

    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },

    opts = {
      ensure_installed = { "vim", "lua", "vimdoc" },
    },
  },

  {
    "IndianBoy42/tree-sitter-just",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
}
