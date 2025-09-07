{
  config.vim = {
    theme = {
      enable = true;
      name = "catppuccin";
      style = "mocha";
    };

    options = {
      colorcolumn = "80";
      termguicolors = true;
      showmode = false;
      cursorline = true;

      number = true;
      relativenumber = true;
      numberwidth = 2;
      ruler = false;
      expandtab = true;
      shiftwidth = 2;
      smartindent = true;
      tabstop = 2;
      softtabstop = 2;

      signcolumn = "yes";
      splitbelow = true;
      splitright = true;
      timeoutlen = 400;
      undofile = true;

      clipboard = "unnamedplus";
      cursorlineopt = "number";

      conceallevel = 2;
    };

    keymaps = [
      # editing
      {
        mode = "n";
        key = "<C-j>";
        action = ":m .+1<CR>==";
        expr = true;
        silent = true;
        desc = "Move line down by [count]";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = ":m .-2<CR>==";
        expr = true;
        silent = true;
        desc = "Move line up by [count]";
      }

      # diagnostics
      {
        mode = "n";
        key = "gef";
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        silent = true;
      }
      {
        mode = "n";
        key = "geq";
        action = "<cmd>lua vim.diagnostic.setqflist()<CR>";
        silent = true;
      }

      # oil
      {
        mode = "n";
        key = "-";
        action = ":Oil<CR>";
        silent = true;
      }
    ];

    treesitter = {
      enable = true;
    };

    languages = {
      enableDAP = true;
      enableExtraDiagnostics = true;
      enableTreesitter = true;

      bash.enable = true;
      csharp.enable = true;
      python = {
        enable = true;
        lsp.server = "pyright";
      };
      haskell.enable = true;
      java.enable = true;
      nix.enable = true;
      rust.enable = true;
      yaml.enable = true;
      zig = {
        enable = true;
        lsp.enable = false;
      };
    };

    telescope.enable = true;

    lsp = {
      enable = true;

      trouble.enable = true;
      otter-nvim.enable = true;
      lspsaga = {
        enable = true;
        setupOpts = {
          symbol_in_winbar.enable = false;
          lightbulb.enable = false;
        };
      };
    };

    autocomplete = {
      blink-cmp = {
        enable = true;
        setupOpts = {
          keymap.preset = "default";
          completion.documentation.auto_show = false;
          sources.default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ];
          fuzzy.implementation = "prefer_rust";
          signature.enabled = true;
          appearance.nerd_font_variant = "mono";
        };
      };
    };

    formatter.conform-nvim = {
      enable = true;
      setupOpts = {
        format_on_save = {
          timeout_ms = 500;
          lsp_fallback = true;
        };

        formatters_by_ft = {
          go = [
            "goimports"
            "gofmt"
          ];
          just = [ "just" ];
          nix = [ "nixfmt" ];
          python = [ "ruff_format" ];
          rust = [ "rustfmt" ];
          zig = [ "zigfmt" ];
        };
      };
    };

    navigation = {
      harpoon = {
        enable = true;
        mappings = {
          listMarks = "<leader>o";
          markFile = "<leader>a";
          file1 = "<leader>1";
          file2 = "<leader>2";
          file3 = "<leader>3";
          file4 = "<leader>4";
        };
      };
    };

    binds = {
      whichKey.enable = true;
    };

    notes = {
      todo-comments.enable = true;
    };

    assistant = {
      # copilot = {
      #   enable = true;
      # };
    };

    git = {
      enable = true;

      vim-fugitive.enable = false;
      neogit = {
        enable = true;
        setupOpts =
          let
            signs = {
              add.text = "";
              change.text = "";
              delete.text = "";
              topdelete.text = "";
              changedelete.text = "";
              untracked.text = "";
            };
          in
          {
            current_line_blame = true;
            signs = signs;
            signs_staged = signs;
          };
      };
    };

    visuals = {
      cellular-automaton.enable = true;
      fidget-nvim.enable = true;
      indent-blankline.enable = true;
      nvim-web-devicons.enable = true;
    };

    utility = {
      motion = {
        leap.enable = true;
      };

      oil-nvim = {
        enable = true;
        setupOpts = {
          columns = [
            "icon"
            "permissions"
            "size"
          ];
        };
      };
      diffview-nvim.enable = true;
    };
  };
}
