{ pkgs, inputs, ... }:

{
  imports = [
    inputs.hyprland.homeManagerModules.default

    ./bindings.nix
    ./settings.nix
    ./window-rules.nix
    ./workspaces.nix

    ./hyprcursor.nix
    ./hyprpaper.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    xwayland.enable = true;
    plugins = [ ];
  };

  home.packages = with pkgs; [
    hyprshot

    libnotify
    dunst

    xwaylandvideobridge
    xdg-utils
  ];
}
