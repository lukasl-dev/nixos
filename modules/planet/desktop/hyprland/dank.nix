{
  atlas,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.desktop) hyprland;
  inherit (pkgs.stdenv.hostPlatform) system;

  inherit (hyprland) cursor;
  steward = atlas.travellers.eval planet.steward.traveller;

  greeterMonitors = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      output: monitor:
      let
        inherit (monitor) mode position;
        scale = toString monitor.scale;
      in
      "monitor = ${output}, ${mode}, ${position}, ${scale}"
    ) hyprland.monitors
  );

  dms = lib.getExe config.programs.dank-material-shell.package;
  toLua = lib.generators.toLua { };
in
{
  imports = [
    inputs.dms.nixosModules.dank-material-shell
    inputs.dms.nixosModules.greeter
  ];

  config = lib.mkIf planet.desktop.enable {
    programs.dank-material-shell = {
      enable = true;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      dgop.package = inputs.dgop.packages.${system}.default;

      greeter = {
        enable = true;
        compositor = {
          name = "hyprland";
          customConfig = ''
            env = DMS_RUN_GREETER,1
            env = XCURSOR_THEME,${cursor.name}
            env = XCURSOR_SIZE,${toString cursor.size}
            env = HYPRCURSOR_THEME,${cursor.name}
            env = HYPRCURSOR_SIZE,${toString cursor.size}

            ${greeterMonitors}
            monitor = Unknown-1, disable

            cursor {
              no_hardware_cursors = 2
            }

            misc {
              disable_hyprland_logo = true
            }

            exec-once = hyprctl setcursor ${cursor.name} ${toString cursor.size}
          '';
        };
        configHome = "/home/${steward.user.name}";
      };
    };

    planet.desktop.hyprland.lua = # lua
      ''
        local dms = ${toLua dms}
        local function dms_call(arguments)
          return hl.dsp.exec_cmd(dms .. " ipc call " .. arguments)
        end

        hl.bind("SUPER + Space", dms_call("spotlight toggle"))
        hl.bind("SUPER + Backspace", dms_call("spotlight toggle"))
        hl.bind("SUPER + V", dms_call("clipboard toggle"))
        hl.bind("SUPER + Tab", dms_call("hypr toggleOverview"))

        hl.bind("XF86AudioRaiseVolume", dms_call("audio increment 3"))
        hl.bind("XF86AudioLowerVolume", dms_call("audio decrement 3"))
        hl.bind("XF86AudioMute", dms_call("audio mute"))
        hl.bind("XF86AudioMicMute", dms_call("audio micmute"))

        hl.bind("SUPER + I", dms_call("audio micmute"))
        hl.bind("SUPER + O", dms_call("audio mute"))

        hl.bind(
          "XF86MonBrightnessUp",
          dms_call([[brightness increment 5 ""]])
        )
        hl.bind(
          "XF86MonBrightnessDown",
          dms_call([[brightness decrement 5 ""]])
        )
      '';
  };
}
