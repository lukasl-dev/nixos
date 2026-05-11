{ pkgs, ... }:

{
  planet.hm = [
    {
      home.packages = [ pkgs.imagemagick ];
    }
  ];
}
