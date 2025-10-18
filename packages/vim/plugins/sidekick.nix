{ pkgs, ... }:

let
  package = pkgs.vimUtils.buildVimPlugin {
    name = "sidekick.nvim";
    pname = "sidekick.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "folke";
      repo = "sidekick.nvim";
      rev = "cefee0d4d8b59488d3d46b720542b50d45d0f3eb";
      hash = "sha256-+uChBKOYqxhrk3NghcX/PsHXYRgI1lJaLbEFOW9mgVg=";
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
