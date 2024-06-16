{ inputs, ... }:

{
  imports = [
    inputs.hyprland.homeManagerModules.default

    ./bindings.nix
    ./window-rules.nix
    ./settings.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    xwayland = {
      enable = true;
    };
    plugins = [];
  };
}
