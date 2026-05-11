{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet.dev) javascript;
in
{
  options.planet.dev.javascript = {
    enable = lib.mkEnableOption "Enable javascript";
  };

  config = lib.mkIf javascript.enable {
    environment.systemPackages = with pkgs.unstable; [ nodejs ];

    universe.hm = [
      {
        programs.bun = {
          enable = true;
          package = pkgs.unstable.bun;
        };
      }
    ];
  };
}
