{ config, lib, ... }:

let
  wm = config.planet.wm;
  hyprland = wm.hyprland;
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
