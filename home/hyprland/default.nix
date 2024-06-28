{ pkgs, inputs, ... }:

{
  imports = [
    inputs.hyprland.homeManagerModules.default

    ./bindings.nix
    ./settings.nix
    ./window-rules.nix

    ./hyprpaper.nix
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

  home.packages = with pkgs; [
    hyprshot
    hyprcursor

    libnotify
    dunst

    xwaylandvideobridge
    xdg-utils
  ];
}

