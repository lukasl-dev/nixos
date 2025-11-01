{ pkgs, ... }:

let
  package = pkgs.vimUtils.buildVimPlugin {
    name = "sidekick.nvim";
    pname = "sidekick.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "folke";
      repo = "sidekick.nvim";
      rev = "c2bdf8cfcd87a6be5f8b84322c1b5052e78e302e";
      hash = "sha256-ABuILCcKfYViZoFHaCepgIMLjvMEb/SBmGqGHUBucAM=";
    };
    nvimSkipModules = [ "sidekick.docs" ];
  };
in
{
  vim.lazy.plugins."sidekick.nvim" = {
    inherit package;
    setupModule = "sidekick";
    setupOpts = {
      cli = {
        mux = {
          enabled = true;
          backend = "tmux";
        };
      };
    };
    event = [ "BufWinEnter" ];
    keys = [
      {
        key = "<tab>";
        mode = [ "n" ];
        lua = true;
        action = # lua
          ''
            function()
              if not require("sidekick").nes_jump_or_apply() then
                return "<Tab>"
              end
            end
          '';
        expr = true;
        desc = "Goto/Apply Next Edit Suggestion";
      }
    ];
  };
}
