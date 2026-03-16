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

    systemd.tmpfiles.rules =
      let
        calDir = "/home/${user.name}/.local/share/calendars/${user.name}";
      in
      [
        "f ${calDir}/43a94c3f-3337-8381-be2d-c424f672ef7d/displayname 0644 ${user.name} users Personal"
        "f ${calDir}/194aace7-1ade-cc79-6fee-75bb65820b9b/displayname 0644 ${user.name} users Lectures"
        "f ${calDir}/e604a983-0407-2e4e-eed0-869bab3de37b/displayname 0644 ${user.name} users Exercises"
        "f ${calDir}/f3567492-3aae-8192-81a8-934ec0ff20f7/displayname 0644 ${user.name} users TISS"
        "f ${calDir}/ff160e4e-7058-92da-5b50-1dea64032920/displayname 0644 ${user.name} users Exams"
        "f ${calDir}/412a1766-0d5b-bd1e-4ade-09f299fdc7ee/displayname 0644 ${user.name} users Tasks"
        "f ${calDir}/f8e10626-5efc-b74b-f111-0b3db45a5ab7/displayname 0644 ${user.name} users Travelling"
      ];

    universe.hm = [
      {
        accounts.calendar.basePath = ".local/share/calendars";

        accounts.calendar.accounts.${user.name} = {
          inherit (user) name;
          primary = true;
          primaryCollection = "Personal";

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
              path = "/home/${user.name}/.local/share/calendars/${user.name}/*"
              date_format = "%d.%m.%Y"
              time_format = "%H:%M"
              datetime_format = "%d.%m.%Y %H:%M"
              list_format = "{start} {summary}"
              default_list = "Personal"
            '';
          };
        };
      }
    ];
  };
}
