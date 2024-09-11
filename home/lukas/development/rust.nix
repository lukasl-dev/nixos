{ pkgs, ... }:

{
  home.packages = with pkgs; [
    rustc
    clippy
    cargo
    rustfmt
  ];
}
