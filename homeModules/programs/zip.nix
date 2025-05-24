{ pkgs, ... }:

{
  home.packages = [
    pkgs.zip
    pkgs.unzip
  ];
}
