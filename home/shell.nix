{ pkgs, ... }:

{
  home.packages = [
    pkgs.gh
    pkgs.just
    pkgs.tree
    pkgs.zip
    pkgs.unzip
    pkgs.speedtest-cli
    pkgs.hyperfine
    pkgs.ffmpeg
    pkgs.imagemagick
    pkgs.jq
  ];
}
