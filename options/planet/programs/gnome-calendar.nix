{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet) wm;

  inherit (config.planet.programs) gnome-calendar;
in
{
  options.planet.programs.gnome-calendar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable GNOME Calendar with CalDAV support";
      example = "true";
    };
  };

  config = lib.mkIf gnome-calendar.enable {
    programs.dconf.enable = lib.mkDefault true;

    services.gnome = {
      evolution-data-server.enable = true;
      gnome-online-accounts.enable = true;
      gnome-keyring.enable = true;
    };

    environment.systemPackages = [
      pkgs.gnome-calendar
      pkgs.evolution
      (pkgs.writeShellScriptBin "gnome-control-center" ''
        export XDG_CURRENT_DESKTOP=GNOME
        exec ${pkgs.gnome-control-center}/bin/gnome-control-center "$@"
      '')
    ];
  };
}
