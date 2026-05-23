{
  imports = [ ./hardware-configuration.nix ];

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
      books.enable = true;
      factorio.enable = true;
      notes.enable = true;
      www.enable = true;
      # TODO:
    };
  };
}
