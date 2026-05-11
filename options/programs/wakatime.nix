{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet.programs) wakatime;
in
{
  options.planet.programs = {
    wakatime = {
      config = lib.mkOption {
        type = lib.types.path;
        description = ".wakatime.cfg file";
      };
    };
  };

  config = {
    environment.systemPackages = with pkgs; [ wakatime-cli ];

    # TODO: symlink wakatime.config to path = "/home/${user.name}/.wakatime.cfg";
  };
}
