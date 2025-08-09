{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  wm = config.planet.wm;
in
{
  services.mullvad-vpn = {
    enable = true;
    package = lib.mkIf wm.enable pkgs-unstable.mullvad-vpn;
  };

  environment.systemPackages = [
    pkgs-unstable.mullvad-vpn
    (lib.mkIf wm.enable pkgs-unstable.mullvad-browser)
  ];
}
