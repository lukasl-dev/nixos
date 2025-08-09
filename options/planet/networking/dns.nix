{ config, lib, ... }:

let
  dns = config.planet.networking.dns;
in
{
  options.planet.networking.dns = {
    providers = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "cloudflare"
          "google"
        ]
      );
      default = [
        "cloudflare"
        "google"
      ];
      description = "A list of DNS providers to use.";
      example = [
        "cloudflare"
        "google"
      ];
    };
  };

  config.networking = {
    networkmanager = {
      enable = true;
      dns = "none";
    };

    nameservers = builtins.concatLists [
      (lib.optionals (lib.elem "cloudflare" dns.providers) [
        "1.1.1.1"
        "1.0.0.1"
      ])
      (lib.optionals (lib.elem "google" dns.providers) [
        "8.8.8.8"
        "8.8.4.4"
      ])
    ];
  };
}
