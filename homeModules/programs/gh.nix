{ pkgs, ... }:

{
  home.packages = [
    pkgs.gh
    pkgs.act
  ];
}
