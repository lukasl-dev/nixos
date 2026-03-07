{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;

  inherit (config.planet) wm;
  inherit (config.planet.programs) ghostty;
in
{
  options.planet.programs.ghostty = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable ghostty";
    };

    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      inherit (inputs.ghostty.packages.${system}) default;
      description = "Package used for Ghostty.";
      example = "inputs.ghostty.packages.${system}.default";
    };
  };

  config = lib.mkIf ghostty.enable {
    nix.settings = {
      extra-substituters = [
        "https://ghostty.cachix.org"
      ];
      extra-trusted-public-keys = [
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      ];
    };

    planet.wm.hyprland.bindings = [
      {
        type = "exec";
        keys = [ "T" ];
        command = lib.getExe ghostty.package;
      }
    ];

    universe.hm = [
      {
        programs.ghostty = {
          enable = true;

          inherit (ghostty) package;

          enableBashIntegration = true;
          enableZshIntegration = true;

          settings = {
            window-decoration = false;
            window-padding-x = 8;
            window-padding-y = 8;

            command = "tmux attach-session || tmux new-session";

            confirm-close-surface = false;

            font-family = "Geist Mono";
            font-style = "Semibold";
            font-size = 12;
          };
        };
      }
    ];
  };
}
