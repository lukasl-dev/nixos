{
  imports = [ ./hardware-configuration.nix ];

  planet = {
    name = "pollux";
    timeZone = "Europe/Berlin";
    stateVersion = "25.05";

    sudo.password = false;
  };

  galaxy = {
    lukasl-dev = {
      enable = true;

      anki.enable = true;
      notes.enable = true;
      www.enable = true;
      # TODO:
    };
  };
}
