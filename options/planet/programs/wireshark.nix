{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet) user;
  inherit (config.planet.programs) wireshark;
in
{
  options.planet.programs = {
    wireshark = {
      enable = lib.mkEnableOption "Enable wireshark";
    };
  };

  config = lib.mkIf wireshark.enable {
    programs.wireshark = {
      enable = true;
      package = pkgs.unstable.wireshark;
    };

    users.users."${user.name}".extraGroups = lib.mkAfter [ "wireshark" ];
  };
}
