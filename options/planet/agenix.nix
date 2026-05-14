{
  inputs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet) name ssh;
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
      hostPubkey = ssh.default.publicKey;
      storageMode = "local";
      localStorageDir = "${toString ../../secrets/_}/${name}";
    };
  };
}
