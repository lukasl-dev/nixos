{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev) factorio;
in
{
  options.galaxy.lukasl-dev = {
    factorio = {
      enable = lib.mkEnableOption "Enable factorio server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 34197;
        readOnly = true;
        description = "Port for the factorio server.";
      };
    };
  };

  config = lib.mkMerge (
    let
      serverSettings = "galaxy/lukasl-dev/factorio/serverSettings";
    in
    [
      {
        age.secrets.${serverSettings} = {
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/factorio/serverSettings.age;
          mode = "0444";
        };
      }

      (lib.mkIf factorio.enable {
        containers.lukasl-dev.forwardPorts = [
          {
            protocol = "udp";
            hostPort = factorio.port;
            containerPort = factorio.port;
          }
        ];

        galaxy.lukasl-dev = {
          backup.paths = [
            "/var/lib/nixos-containers/lukasl-dev/var/lib/private/factorio"
          ];

          bindMounts = [ age.secrets.${serverSettings}.path ];

          modules = [
            {
              services.factorio = {
                enable = true;
                package = pkgs.unstable.factorio-headless;

                openFirewall = true;
                admins = [ "argsvl" ];

                extraSettingsFile = age.secrets.${serverSettings}.path;
              };

              networking.firewall.allowedUDPPorts = [ factorio.port ];
            }
          ];
        };
      })
    ]
  );
}
