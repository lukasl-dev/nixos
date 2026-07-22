{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
in
{
  config = lib.mkIf planet.gaming.enable {
    environment.systemPackages = with pkgs; [
      protonplus
      protonup-qt
    ];
  };
}
