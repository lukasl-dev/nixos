{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.programs) seahorse;
in
{
  options.planet.programs.seahorse.enable = lib.mkOption {
    type = lib.types.bool;
    default = planet.desktop.enable;
    description = "Enable Seahorse key and password management.";
  };

  config = lib.mkIf seahorse.enable {
    programs.seahorse.enable = true;
    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = [ pkgs.libsecret ];
  };
}
