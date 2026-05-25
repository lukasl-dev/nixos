{
  imports = [
    ./hardware-configuration.nix

    ./boot.nix
    ./networking.nix
  ];

  planet = {
    name = "pollux";
    timeZone = "Europe/Berlin";
    stateVersion = "25.05";

    sudo.password = false;
  };

  galaxy = {
    acme = {
      enable = true;
      email = "contact@lukasl.dev";
    };

    lukasl-dev = {
      enable = true;

      anki.enable = true;
      attic.enable = true;
      books.enable = true;
      box.enable = true;
      cal.enable = true;
      factorio.enable = true;
      forge = {
        enable = true;
        runner.enable = true;
      };
      mail.enable = true;
      matrix.enable = true;
      notes.enable = true;
      term.enable = true;
      vault.enable = true;
      waka.enable = true;
      www.enable = true;
      yam.enable = true;
    };
  };
}
