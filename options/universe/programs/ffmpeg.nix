{ pkgs, ... }:

{
  universe.hm = [
    {
      home.packages = [ pkgs.ffmpeg ];
    }
  ];
}
