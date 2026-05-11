{ config, ... }:

let
  meta = import ./meta.nix;
  port = 34197;
in
{
  age.secrets."planets/pollux/lukasl.dev/factorio/server_settings" = {
    rekeyFile = ../../../../secrets/planets/pollux/lukasl.dev/factorio/server_settings.age;
    mode = "0400";
  };

  pollux.containers.${meta.container} = [
    (
      { pkgs, ... }:
      {
        services.factorio = {
          enable = true;
          openFirewall = true;
          package = pkgs.unstable.factorio-headless;
          admins = [ "argsvl" ];
          extraSettingsFile = config.age.secrets."planets/pollux/lukasl.dev/factorio/server_settings".path;
        };
      }
    )
  ];

  containers.${meta.container} = {
    bindMounts.${config.age.secrets."planets/pollux/lukasl.dev/factorio/server_settings".path} = {
      hostPath = config.age.secrets."planets/pollux/lukasl.dev/factorio/server_settings".path;
      isReadOnly = true;
    };

    forwardPorts = [
      {
        protocol = "udp";
        hostPort = port;
        containerPort = port;
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ port ];
}
