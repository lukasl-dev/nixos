{ pkgs, ... }:

{
  home.packages = [
    pkgs.nixd
    pkgs.nixfmt-rfc-style
  ];
}
