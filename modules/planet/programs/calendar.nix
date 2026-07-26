{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.programs) calendar;
in
{
  options.planet.programs.calendar.enable = lib.mkOption {
    type = lib.types.bool;
    default = planet.desktop.enable;
    description = "Enable calendar and task management.";
  };

  config = lib.mkIf calendar.enable {
    environment.systemPackages = [ pkgs.planify ];

    programs.dconf.enable = true;

    services.gnome = {
      evolution-data-server.enable = true;
      gnome-online-accounts.enable = true;
      gnome-keyring.enable = true;
    };
  };
}
