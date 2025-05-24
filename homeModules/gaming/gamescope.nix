{ pkgs, ... }:

{
  home.packages = [
    pkgs.gamescope
    pkgs.gamescope-wsi
  ];
}
