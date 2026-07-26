{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
in
{
  config = lib.mkIf planet.gaming.enable {
    programs.gamescope = {
      enable = true;

      package = pkgs.gamescope.overrideAttrs (old: {
        NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or [ ]) ++ [
          "-fno-fast-math"
        ];
      });
    };

    environment.systemPackages = [ pkgs.gamescope-wsi ];
  };
}
