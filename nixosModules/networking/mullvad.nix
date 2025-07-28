{ pkgs-unstable, ... }:

{
  services.mullvad-vpn = {
    enable = true;
    package = pkgs-unstable.mullvad-vpn; # TODO: only on desktops
  };

  environment.systemPackages = [
    pkgs-unstable.mullvad-vpn
    pkgs-unstable.mullvad-browser
  ];
}
