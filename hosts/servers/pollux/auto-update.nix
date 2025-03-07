{ meta, ... }:

let
  serviceName = "auto-update";
in
{
  systemd.services.${serviceName} = {
    description = "Automatically update the system";
    script = ''
      cd /home/${meta.user.name}/nixos
      git pull
      sudo just switch pollux
    '';
    serviceConfig = {
      User = meta.user.name;
    };
  };

  systemd.timers.${serviceName} = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Unit = "${serviceName}.service";
    };
  };
}
