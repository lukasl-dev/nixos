{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];

  planet = {
    name = "ida";
    timeZone = "Europe/Vienna";

    sudo.password = false;
  };
}
