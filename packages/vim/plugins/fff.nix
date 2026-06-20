{ pkgs, rinputs, ... }:

{
  vim.extraPlugins."fff.nvim" = {
    package = rinputs.fff.packages.${pkgs.stdenv.hostPlatform.system}.fff-nvim;
    setup = # lua
      ''
        require("fff").setup {
          prompt = '> ',
          title = 'Find files',
          max_threads = 8,
          ui = {
            width = 0.8,
            height = 0.8,
          },
          file_picker = {
            auto_reload_on_write = true,
            frecency_boost = true,
          },
          preview = {
            line_numbers = true,
          },
        }
      '';
  };

  vim.keymaps = [
    {
      key = "<leader>ff";
      mode = [ "n" ];
      lua = true;
      action = # lua
        ''
          function()
            require("fff").find_files()
          end
        '';
      desc = "Files [FFF]";
    }
    {
      key = "<leader>fw";
      mode = [ "n" ];
      lua = true;
      action = # lua
        ''
          function()
            require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
          end
        '';
      desc = "Live grep [FFF]";
    }
  ];
}
