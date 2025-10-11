{
  inputs,
  config,
  lib,
  ...
}:

lib.mkIf config.planet.wm.enable {
  universe.hm = [
    {
      imports = [ inputs.caelestia-shell.homeManagerModules.default ];

      programs.caelestia = {
        enable = true;
        systemd = {
          enable = true;
          target = "graphical-session.target";
          environment = [ ];
        };
        settings = {
          appearance.rounding.scale = 2;
          bar = {
            entries = [
              {
                id = "logo";
                enabled = true;
              }
              {
                id = "workspaces";
                enabled = true;
              }
              {
                id = "spacer";
                enabled = true;
              }
              {
                id = "activeWindow";
                enabled = false;
              }
              {
                id = "spacer";
                enabled = true;
              }
              {
                id = "tray";
                enabled = true;
              }
              {
                id = "clock";
                enabled = true;
              }
              {
                id = "statusIcons";
                enabled = true;
              }
              {
                id = "power";
                enabled = false;
              }
            ];
            tray.recolour = true;
          };
          paths.wallpaperDir = ././../../../wallpapers;
        };
        cli = {
          enable = true;
          settings = {
            theme.enableGtk = true;
          };
        };
      };

      # services.cliphist.enable = true;
    }
  ];
}
