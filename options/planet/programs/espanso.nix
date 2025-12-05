{ config, lib, ... }:

let
  wm = config.planet.wm;
  hyprland = wm.hyprland;
  user = config.universe.user;
in
{
  options.planet.programs.espanso = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable espanso";
    };
  };

  config = lib.mkIf config.planet.programs.espanso.enable {
    hardware.uinput.enable = true;

    users.users.${user.name}.extraGroups = lib.mkAfter [
      "uinput"
      "input"
    ];

    universe.hm = [
      {
        services.espanso = {
          enable = true;
          waylandSupport = hyprland.enable;
          x11Support = !hyprland.enable;

          configs = {
            default = {
              keyboard_layout = {
                layout = "us";
              };
            };
          };

          matches = {
            emdash = {
              matches = [
                {
                  trigger = "\\emdash";
                  replace = "—";
                }
                {
                  trigger = "\\ae";
                  replace = "ä";
                }
                {
                  trigger = "\\Ae";
                  replace = "Ä";
                }
                {
                  trigger = "\\oe";
                  replace = "ö";
                }
                {
                  trigger = "\\Oe";
                  replace = "Ö";
                }
                {
                  trigger = "\\ue";
                  replace = "ü";
                }
                {
                  trigger = "\\Ue";
                  replace = "Ü";
                }
              ];
            };
          };
        };

        systemd.user.services.espanso = lib.mkIf hyprland.enable {
          Unit = {
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
        };
      }
    ];
  };
}
