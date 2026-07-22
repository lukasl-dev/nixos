{ inputs, config, ... }:

let
  inherit (config) planet;
in
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];

  age = {
    identityPaths = [ "/etc/agenix/identity" ];

    rekey = {
      masterIdentities = [ "/etc/agenix/identity" ];
      hostPubkey = planet.keys.public;
      storageMode = "local";
      localStorageDir = ../.. + "/secrets/_/${planet.name}";
    };
  };
}
