{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.planet.programs.wireshark = {
    enable = lib.mkEnableOption "Enable wireshark";
  };

  config = lib.mkIf config.planet.programs.wireshark.enable {
    programs.wireshark = {
      enable = true;
      package = pkgs.unstable.wireshark;
    };
  };
}
