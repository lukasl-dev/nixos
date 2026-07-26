{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ffmpeg ];
}
