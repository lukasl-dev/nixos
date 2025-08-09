{ pkgs, ... }:

{
  universe.hm = [
    {
      home.packages = [ pkgs.hyperfine ];
    }
  ];
}
