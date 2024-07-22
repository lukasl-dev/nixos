return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- format on save
    config = function()
      require "configs.conform"
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "html-lsp",
        "css-lsp",
        "biome",
        "yaml-language-server",
        "gopls",
        "gospel",
        "dockerfile-language-server",
        "docker-compose-language-server",
        "tailwindcss-language-server",
        "pyright",
        "ruff-lsp",
        "zls",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "markdown",
        "javascript",
        "typescript",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "dockerfile",
        "bibtex",
        "bash",
        "fish",
        "json",
        "csv",
        "yaml",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitignore",
        "gitcommit",
        "diff",
        "gleam",
        "graphql",
        "nix",
        "python",
        "zig",
        "make",
      },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      local conf = require "nvchad.configs.telescope"

      conf.defaults.mappings.i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
        ["<Esc>"] = require("telescope.actions").close,
      }

      return conf
    end,
  },

  {
    "olimorris/codecompanion.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
      {
        "stevearc/dressing.nvim",
        opts = {},
      },
    },
    config = function()
      require "configs.codecompanion"
    end,
  },

  {
    "github/copilot.vim",
    event = "BufWinEnter",
    config = function()
      vim.g.copilot_no_tab_map = true
    end,
  },

  {
    "olexsmir/gopher.nvim",
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("gopher").setup()
    end,
  },

  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    ft = { "python" },
    init = function()
      vim.g.molten_output_win_max_height = 20
      -- vim.g.molten_image_provider = "image.nvim"
    end,
  },

  -- {
  --   -- see the image.nvim readme for more information about configuring this plugin
  --   "3rd/image.nvim",
  --   dependencies = { "luarocks.nvim" },
  --   opts = {
  --     backend = "kitty", -- whatever backend you would like to use
  --     max_width = 100,
  --     max_height = 12,
  --     max_height_window_percentage = math.huge,
  --     max_width_window_percentage = math.huge,
  --     window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
  --     window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
  --   },
  -- },

  {
    "vhyrro/luarocks.nvim",
    priority = 1001, -- this plugin needs to run before anything else
    opts = {
      rocks = { "magick" },
    },
  },

  {
    "tpope/vim-fugitive",
    event = "BufWinEnter",
  },

  {
    "tpope/vim-dispatch",
    event = "VeryLazy",
  },

  {
    "folke/trouble.nvim",
    event = "BufWinEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  {
    "marilari88/twoslash-queries.nvim",
    event = "BufRead",
  },

  {
    "stevearc/oil.nvim",
    event = "BufWinEnter",
    opts = {
      columns = {
        "icon",
        "permissions",
        "size",
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
    },
  },

  {
    "lervag/vimtex",
    lazy = false, -- we don"t want to lazy load VimTeX
    config = function()
      -- Use LuaLateX for vimtex
      vim.g.vimtex_compiler_latexmk = {
        options = {
          "-lualatex", -- TOOD: should be dependent on the directory
          "-silent",
          "-synctex=1",
          "-shell-escape",
          "-interaction=nonstopmode",
        },
      }

      vim.g.vimtex_view_method = "sioyek"
    end,
  },

  {
    "rafcamlet/nvim-luapad",
    cmd = "Luapad",
  },

  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory"
    },
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufWinEnter",
    opts = {},
  },

  {
    "MeanderingProgrammer/markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    opts = {},
  }
}
