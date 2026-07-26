{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;

  startHyprland = lib.getExe' config.programs.hyprland.package "start-hyprland";
  session = pkgs.writeShellScript "start-hyprland-session" ''
    exec ${startHyprland} -- \
      --config "$HOME/.config/hypr/hyprland.lua"
  '';
in
{
  config = lib.mkIf planet.desktop.enable {
    programs = {
      hyprland.withUWSM = true;

      uwsm.waylandCompositors.hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland compositor managed by UWSM";
        binPath = session;
      };
    };

    services = {
      displayManager.defaultSession = "hyprland-uwsm";

      # Avoid activation failures while switching existing systems to UWSM.
      dbus.implementation = lib.mkForce "dbus";
    };
  };
}
