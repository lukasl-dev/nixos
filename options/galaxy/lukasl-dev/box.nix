{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev) addresses box;

  isGuest = box.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";
  stateDir = "/var/lib/homebox";

  module = {
    services.homebox = {
      enable = true;

      settings = {
        HBOX_WEB_PORT = toString box.port;
        HBOX_WEB_HOST = listenAddress;
        HBOX_OPTIONS_ALLOW_REGISTRATION = "false";
        HBOX_OPTIONS_GITHUB_RELEASE_CHECK = "false";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf isGuest [ box.port ];
  };
in
{
  options.galaxy.lukasl-dev = {
    box = {
      enable = lib.mkEnableOption "Enable homebox server";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run homebox in the lukasl-dev container or on the host.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 7745;
        readOnly = true;
        description = "Port for the homebox server.";
      };
    };
  };

  config = lib.mkIf box.enable (
    lib.mkMerge [
      {
        galaxy.lukasl-dev = {
          proxy.rules = [
            {
              type = "https";
              name = "box";
              to.http = "http://${listenAddress}:${toString box.port}";
            }
          ];

          backup.paths = [
            (if isGuest then "/var/lib/nixos-containers/lukasl-dev${stateDir}" else stateDir)
          ];

          modules.box = {
            inherit (box) mode;
            inherit module;
          };
        };
      }

      (lib.mkIf (!isGuest) module)
    ]
  );
}
