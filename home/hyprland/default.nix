{ inputs, ... }:

{
  imports = [
    inputs.hyprland.homeManagerModules.default
    # inputs.hyprlock.homeManagerModules.hyprlock

    ./bindings.nix
    ./hyprpaper.nix
    ./settings.nix
    ./window-rules.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    xwayland.enable = true;
    plugins = [];
  };
}

