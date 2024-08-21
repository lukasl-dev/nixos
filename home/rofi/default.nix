{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    pass.enable = true;
  };

  home.packages = with pkgs; [ bemoji ];
}
