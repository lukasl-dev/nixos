{ pkgs, ... }:

{
  vim.extraPlugins."fff.nvim" = {
    package = pkgs.vimPlugins.fff-nvim;
    setup = # lua
      ''
        require("fff").setup {
          prompt = '> ',
          title = 'Find files',
          max_threads = 8,
          preview = {
              line_numbers = true,
              show_file_info = false,
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
  ];
}
