{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev) addresses domain household;

  isGuest = household.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";
  stateDir = "/var/lib/grocy";

  module = {
    services.grocy = {
      enable = true;
      hostName = household.host;
      nginx.enableSSL = false;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf isGuest [ 80 ];
  };
in
{
  options.galaxy.lukasl-dev = {
    household = {
      enable = lib.mkEnableOption "Enable Grocy";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run Grocy in the lukasl-dev container or on the host.";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "household.${domain}";
        readOnly = true;
        description = "Public hostname for Grocy.";
      };
    };
  };

  config = lib.mkIf household.enable (
    lib.mkMerge [
      {
        galaxy.lukasl-dev = {
          proxy.rules = [
            {
              type = "https";
              name = "household";
              from.host = household.host;
              to.http = "http://${listenAddress}";
            }
          ];

          backup.paths = [
            (if isGuest then "/var/lib/nixos-containers/lukasl-dev${stateDir}" else stateDir)
          ];

          modules.household = {
            inherit (household) mode;
            inherit module;
          };
        };
      }

      (lib.mkIf (!isGuest) module)
    ]
  );
}
