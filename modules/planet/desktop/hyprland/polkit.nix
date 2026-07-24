{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  agent = pkgs.hyprpolkitagent;
in
{
  config = lib.mkIf planet.desktop.enable {
    security.polkit.enable = true;

    systemd.user.services = {
      hyprpolkitagent = {
        description = "Hyprland Polkit authentication agent";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];

        unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";

        serviceConfig = {
          ExecStart = "${agent}/libexec/hyprpolkitagent";
          Slice = "session.slice";
          TimeoutStopSec = "5s";
          Restart = "on-failure";
        };
      };

      link-user-keyring = {
        description = "Link the user keyring into the session keyring";
        wantedBy = [ "graphical-session.target" ];
        before = [ "hyprpolkitagent.service" ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe' pkgs.keyutils "keyctl"} link @u @s";
          RemainAfterExit = true;
        };
      };
    };
  };
}
