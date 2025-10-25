{
  inputs,
  config,
  lib,
  ...
}:

let
  wm = config.planet.wm;
in
{
  options.planet.programs.ghostty = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable ghostty";
    };
  };

  config = lib.mkIf config.planet.programs.ghostty.enable {
    nix.settings = {
      substituters = [
        "https://ghostty.cachix.org"
      ];
      trusted-public-keys = [
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      ];
    };

    # environment.systemPackages = [
    #   inputs.ghostty.packages.x86_64-linux.default
    # ];

    # hjem.users.${user.name}.files.".config/ghostty/config".source = ./config;

    universe.hm = [
      {
        # home.file.".config/ghostty/config".source = ./config;

        programs.ghostty = {
          enable = true;

          package = inputs.ghostty.packages.x86_64-linux.default;

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
