{ config, ... }:

let
  user = config.universe.user;
  homeDir = config.home-manager.users.${user.name}.home.homeDirectory;
in
{
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "${homeDir}/nixos";
  };
}
