{
  pkgs, lib, ... }:

{
  options.planet.development.java = {
    enable = lib.mkEnableOption "Enable java";
  };

  config = {
    programs.java = {
      enable = true;
      package = pkgs.unstable.zulu21;
    };
  };
}
