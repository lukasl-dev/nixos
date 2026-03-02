{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet.dev) java;
in
{
  options.planet.dev.java = {
    enable = lib.mkEnableOption "Enable java";
  };

  config = lib.mkIf java.enable {
    programs.java = {
      enable = true;
      package = pkgs.unstable.zulu21;
    };
  };
}
