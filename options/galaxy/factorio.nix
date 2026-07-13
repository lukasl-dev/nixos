{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy) factorio;

  stateDir = "/var/lib/private/factorio";

  serverSettings = "galaxy/factorio/serverSettings";

  module = {
    services.factorio = {
      enable = true;
      package = pkgs.unstable.factorio-headless;

      openFirewall = true;
      admins = [ "argsvl" ];

      extraSettingsFile = age.secrets.${serverSettings}.path;
    };

  };
in
{
  options.galaxy = {
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

  config = lib.mkMerge [
    {
      age.secrets.${serverSettings} = {
        rekeyFile = ../../secrets/galaxy/factorio/serverSettings.age;
        mode = "0444";
      };
    }

    (lib.mkIf factorio.enable (
      lib.mkMerge [
        module
        {
          galaxy.backup.paths = [ stateDir ];
        }
      ]
    ))
  ];
}
