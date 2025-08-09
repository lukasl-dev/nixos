{ pkgs, ... }:

{
  universe.hm = [
    {
      home.packages = [ pkgs.imagemagick ];
    }
  ];
}
