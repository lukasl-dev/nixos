{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet.display) hyprland;
in
{
  imports = [ inputs.dms.nixosModules.dank-material-shell ];

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
