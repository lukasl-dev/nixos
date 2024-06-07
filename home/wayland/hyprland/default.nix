{ inputs, pkgs, ... }:

{
  imports = [
    ./bindings.nix
    ./settings.nix
  ];

  wayland = {
    windowManager = {
      hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.default;
        systemd = {
          # enable = true;
          variables = [ "--all" ];
        };
      };
    };
  };
}
