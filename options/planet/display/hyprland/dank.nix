{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) user;
  inherit (config.planet.display) hyprland;

  cursorName = "Catppuccin-Mocha-Light-Cursors";
  cursorSize = 26;

  greeterMonitorConfig = lib.concatMapStringsSep "\n" (
    monitor: "monitor = ${monitor.output}, ${monitor.mode}, ${monitor.position}, ${toString monitor.scale}"
  ) hyprland.monitors;
in
{
  imports = [
    inputs.dms.nixosModules.dank-material-shell
    inputs.dms.nixosModules.greeter
  ];

  config = lib.mkIf hyprland.enable {
    programs.dank-material-shell = {
      enable = true;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      enableSystemMonitoring = true;
      enableVPN = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;

      dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;

      greeter = {
        enable = true;
        compositor = {
          name = "hyprland";
          customConfig = ''
            env = DMS_RUN_GREETER,1
            env = XCURSOR_THEME,${cursorName}
            env = XCURSOR_SIZE,${toString cursorSize}
            env = HYPRCURSOR_THEME,${cursorName}
            env = HYPRCURSOR_SIZE,${toString cursorSize}

            ${greeterMonitorConfig}
            monitor = Unknown-1, disable

            cursor {
              no_hardware_cursors = 2
            }

            misc {
              disable_hyprland_logo = true
            }

            exec-once = hyprctl setcursor ${cursorName} ${toString cursorSize}
          '';
        };
        configHome = "/home/${user.name}";
      };
    };

    planet.display.hyprland.lua = [
      # lua
      ''
        hl.bind("SUPER + Space", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))
        hl.bind("SUPER + Backspace", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))
        hl.bind("SUPER + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
        hl.bind("SUPER + Tab", hl.dsp.exec_cmd("dms ipc call hypr toggleOverview"))

        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("dms ipc call audio increment 3"))
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("dms ipc call audio decrement 3"))
        hl.bind("XF86AudioMute", hl.dsp.exec_cmd("dms ipc call audio mute"))

        hl.bind("SUPER + I", hl.dsp.exec_cmd("dms ipc call audio micmute"))
        hl.bind("SUPER + O", hl.dsp.exec_cmd("dms ipc call audio mute"))

        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("dms ipc call brightness increment 5"))
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("dms ipc call brightness decrement 5"))
      ''
    ];
  };
}
