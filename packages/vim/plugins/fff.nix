{ rinputs, pkgs, ... }:

{
  vim.lazy.plugins."fff.nvim" = {
    package = rinputs.fff-nvim.packages.${pkgs.stdenv.system}.fff-nvim;
    setupOpts = {
      prompt = "> ";
    };
    keys = [
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
  };
}
