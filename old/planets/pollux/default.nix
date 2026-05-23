{
  imports = [
    ./hardware-configuration.nix
    ./acme.nix
    ./boot.nix
    ./networking.nix

    ./containers
    ./options

    ./traefik.nix

    # ./services/anki-sync-server.nix
    ./services/attic.nix
    ./services/forgejo.nix
    ./services/blog.nix
    # ./services/firefly.nix
    ./services/freshrss.nix
    ./services/maddy.nix
    ./services/outofbounds.nix
    ./services/nginx.nix
    ./services/notes.nix
    # ./services/seafile.nix
    ./services/restic.nix
    # ./services/coturn.nix
    # ./services/traefik.nix
    ./services/tuwunel.nix
    ./services/vaultwarden.nix
    ./services/woodpecker.nix
    ./services/www.nix
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.settings.extra-platforms = [ "aarch64-linux" ];

  planet = {
    name = "pollux";
    timeZone = "Europe/Berlin";
    stateVersion = "25.05";

    sudo.password = false;
  };

  # users.users.${user.name}.linger = true;
}
