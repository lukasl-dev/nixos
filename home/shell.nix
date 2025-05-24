{ pkgs, ... }:

{
  home.packages = [
    pkgs.gh
    pkgs.just
    pkgs.speedtest-cli
    pkgs.hyperfine
    pkgs.ffmpeg
    pkgs.imagemagick
    pkgs.jq
  ];
}
