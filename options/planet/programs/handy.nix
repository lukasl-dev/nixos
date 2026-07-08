{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) display;
  inherit (config.planet.display) hyprland;
  inherit (config.planet.programs) handy;
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  options.planet.programs.handy = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = display.enable;
      description = "Enable Handy, an offline speech-to-text desktop app";
    };

    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = inputs.handy.packages.${system}.handy;
      description = "Package used for Handy.";
    };
  };

  config = lib.mkIf handy.enable {
    environment.systemPackages = [
      handy.package

      # Handy needs a typing tool to simulate paste shortcuts on Wayland.
      # Upstream recommends wtype for Hyprland/sway.
      pkgs.wtype
    ];

    planet.display.hyprland = lib.mkIf hyprland.enable {
      autoStart = [ "${lib.getExe handy.package} --start-hidden" ];

      lua = [
        # lua
        ''
          -- Handy's own global shortcuts are unreliable on Wayland. Upstream
          -- recommends compositor bindings that signal the running instance.
          hl.bind("SUPER + C", hl.dsp.exec_cmd("sleep 0.25; pkill -USR2 -x handy || pkill -USR2 -x .handy-wrapped"), { release = true })
        ''
      ];
    };
  };
}
