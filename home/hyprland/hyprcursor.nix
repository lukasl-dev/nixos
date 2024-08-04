{ inputs, pkgs, ... }:

let
  themeDir = "${pkgs.catppuccin-cursors.mochaLight}/share/icons/";
  theme = "Catppuccin-Mocha-Light-Cursors";
in
{
  wayland.windowManager.hyprland.settings = {
    env = [
      "HYPRCURSOR_SIZE,26"
      "HYPRCURSOR_THEME,${theme}"
    ];
  };

  home.file.".icons" = {
    enable = true;
    source = themeDir;
    target = ".icons";
  };

  home.packages = with pkgs; [
    hyprcursor
    catppuccin-cursors.mochaMauve
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
  ];
}
