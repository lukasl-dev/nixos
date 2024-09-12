{ pkgs-unstable, ... }:

{
  programs.gamescope = {
    enable = true;
    package = pkgs-unstable.gamescope;
  };
}
