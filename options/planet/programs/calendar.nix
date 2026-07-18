{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet) display;

  inherit (config.planet.programs) calendar;
in
{
  options.planet.programs.calendar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = display.enable;
      description = "Enable calendar";
      example = "true";
    };
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
