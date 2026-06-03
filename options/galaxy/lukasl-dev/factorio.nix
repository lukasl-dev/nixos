{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev) factorio;

  isGuest = factorio.mode == "guest";
  stateDir = "/var/lib/private/factorio";

  serverSettings = "galaxy/lukasl-dev/factorio/serverSettings";

  module = {
    services.factorio = {
      enable = true;
      package = pkgs.unstable.factorio-headless;

      openFirewall = true;
      admins = [ "argsvl" ];

      extraSettingsFile = age.secrets.${serverSettings}.path;
    };

    networking.firewall.allowedUDPPorts = lib.mkIf isGuest [ factorio.port ];
  };
in
{
  options.galaxy.lukasl-dev = {
    factorio = {
      enable = lib.mkEnableOption "Enable factorio server";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run the Factorio server in the lukasl-dev container or on the host.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 34197;
        readOnly = true;
        description = "Port for the factorio server.";
      };
    };
  };

  config = lib.mkMerge [
    {
      age.secrets.${serverSettings} = {
        rekeyFile = ../../../secrets/galaxy/lukasl-dev/factorio/serverSettings.age;
        mode = "0444";
      };
    }

    (lib.mkIf factorio.enable (
      lib.mkMerge [
        {
          galaxy.lukasl-dev = {
            backup.paths = [
              (if isGuest then "/var/lib/nixos-containers/lukasl-dev${stateDir}" else stateDir)
            ];

            bindMounts = lib.mkIf isGuest [ age.secrets.${serverSettings}.path ];

            modules.factorio = {
              inherit (factorio) mode;
              inherit module;
            };
          };
        }

        (lib.mkIf isGuest {
          containers.lukasl-dev.forwardPorts = [
            {
              protocol = "udp";
              hostPort = factorio.port;
              containerPort = factorio.port;
            }
          ];
        })

        (lib.mkIf (!isGuest) module)
      ]
    ))
  ];
}
