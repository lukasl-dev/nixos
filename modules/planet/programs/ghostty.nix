{
  atlas,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) catppuccin planet;
  inherit (planet.programs) ghostty;
  inherit (pkgs.stdenv.hostPlatform) system;

  package = inputs.ghostty.packages.${system}.default;
  theme = "catppuccin-${catppuccin.flavor}";
in
{
  options.planet.programs.ghostty.enable = lib.mkEnableOption "Ghostty" // {
    default = planet.desktop.enable;
    defaultText = lib.literalExpression "config.planet.desktop.enable";
  };

  config = lib.mkIf ghostty.enable {
    nix.settings = {
      extra-substituters = [ "https://ghostty.cachix.org" ];
      extra-trusted-public-keys = [
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      ];
    };

    environment.systemPackages = [ package ];

    hjem.users = atlas.travellers.forEach planet (_: {
      files.".bashrc".text = lib.mkAfter ''
        if [[ -n "''${GHOSTTY_RESOURCES_DIR-}" ]]; then
          ghosttyIntegration="''${GHOSTTY_RESOURCES_DIR}/shell-integration"
          builtin source "$ghosttyIntegration/bash/ghostty.bash"
          unset ghosttyIntegration
        fi
      '';

      xdg.config.files."ghostty/themes/${theme}".source =
        "${catppuccin.sources.ghostty}/${theme}.conf";

      rum.programs = {
        ghostty = {
          enable = true;
          package = null;

          settings = {
            theme = "light:${theme},dark:${theme}";

            window-decoration = false;
            window-padding-x = 8;
            window-padding-y = 8;

            command = "herdr";

            confirm-close-surface = false;
            app-notifications = false;

            font-family = "Geist Mono";
            font-style = "Semibold";
            font-size = 12;
          };
        };

        zsh.initConfig = lib.mkAfter ''
          if [[ -n "''${GHOSTTY_RESOURCES_DIR-}" ]]; then
            ghosttyIntegration="''${GHOSTTY_RESOURCES_DIR}/shell-integration"
            builtin source "$ghosttyIntegration/zsh/ghostty-integration"
            unset ghosttyIntegration
          fi
        '';
      };
    });
  };
}
