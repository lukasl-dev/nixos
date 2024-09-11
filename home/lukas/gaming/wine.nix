{ pkgs, ... }:

{
  home.packages = with pkgs; [ wineWowPackages.waylandFull ];
}
