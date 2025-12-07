{ pkgs-unstable, lib, ... }:

{
  options.planet.development.R = {
    enable = lib.mkEnableOption "Enable R";
  };

  config = {
    environment.systemPackages = with pkgs-unstable; [ R ];
  };
}
