{ pkgs, lib, ... }:

let
  package = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-soil";
    pname = "nvim-soil";
    src = pkgs.fetchFromGitHub {
      owner = "javiorfo";
      repo = "nvim-soil";
      rev = "e464c5532b2737e2a489526bdc984e1b17d6ae26";
      hash = "sha256-mlcp8IRg4s2H7UjCi1SvwmRMnDIeAbgbTiG9afAYiWI=";
    };
  };
in
{
  vim = {
    extraPackages = [ pkgs.plantuml ];

    lazy.plugins."nvim-soil" = {
      inherit package;
      setupModule = "soil";

      ft = [ "plantuml" ];
      cmd = [ "Soil" ];

      setupOpts = {
        actions = {
          redraw = false;
        };
        image = {
          darkmode = true;
          format = "png"; # or "svg"
          execute_to_open = lib.generators.mkLuaInline ''
            function(img)
              return "xdg-open " .. img
            end
          '';
        };
      };
    };
  };
}
