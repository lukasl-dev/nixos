{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  wm = config.planet.wm;

  mullvad = config.planet.services.mullvad;
in
{
  options.planet.services.mullvad = {
    enable = lib.mkEnableOption "Enable mullvad vpn";
  };

  config = lib.mkIf mullvad.enable {
    services.mullvad-vpn = {
      enable = true;
      package = lib.mkIf wm.enable pkgs-unstable.mullvad-vpn;
    };

    environment.systemPackages = [
      pkgs-unstable.mullvad-vpn
      (lib.mkIf wm.enable pkgs-unstable.mullvad-browser)
    ];
  };
}
