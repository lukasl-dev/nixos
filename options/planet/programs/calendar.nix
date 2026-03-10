{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet) wm;

  inherit (config.universe) domain user;
  inherit (config.planet.programs) calendar;
in
{
  options.planet.programs.calendar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable calendar support (GNOME Calendar, vdirsyncer, etc.)";
      example = "true";
    };
  };

  config = lib.mkIf calendar.enable {
    programs.dconf.enable = lib.mkDefault true;

    services.gnome = {
      evolution-data-server.enable = true;
      gnome-online-accounts.enable = true;
      gnome-keyring.enable = true;
    };

    age.secrets."universe/cal/password" = {
      rekeyFile = ../../../secrets/universe/cal/password.age;
      owner = user.name;
      mode = "0400";
    };

    environment.systemPackages = [
      pkgs.gnome-calendar
      pkgs.evolution
      pkgs.vdirsyncer
      pkgs.khal
      pkgs.todoman
      (pkgs.writeShellScriptBin "gnome-control-center" ''
        export XDG_CURRENT_DESKTOP=GNOME
        exec ${pkgs.gnome-control-center}/bin/gnome-control-center "$@"
      '')
    ];

    universe.hm = [
      {
        accounts.calendar.basePath = ".local/share/calendars";

        accounts.calendar.accounts.${user.name} = {
          inherit (user) name;
          primary = true;
          primaryCollection = "43a94c3f-3337-8381-be2d-c424f672ef7d"; # "Personal"

          remote = {
            type = "caldav";
            url = "https://cal.${domain}/";
            userName = user.name;
            passwordCommand = [
              "cat"
              config.age.secrets."universe/cal/password".path
            ];
          };

          vdirsyncer = {
            enable = true;
            collections = [
              "from a"
              "from b"
            ];
            conflictResolution = "remote wins";
          };

          khal = {
            enable = true;
            type = "discover";
            color = "dark blue";
          };
        };

        programs = {
          vdirsyncer.enable = true;

          khal = {
            enable = true;
            locale = {
              timeformat = "%H:%M";
              dateformat = "%d.%m.%Y";
              longdateformat = "%d.%m.%Y";
              datetimeformat = "%d.%m.%Y %H:%M";
              longdatetimeformat = "%d.%m.%Y %H:%M";
            };
          };

          todoman = {
            enable = true;
            extraConfig = ''
              date_format = "%d.%m.%Y"
              time_format = "%H:%M"
              datetime_format = "%d.%m.%Y %H:%M"
              list_format = "{start} {summary}"
              default_list = "${user.name}"
            '';
          };
        };
      }
    ];
  };
}
