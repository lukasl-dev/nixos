{
  config,
  inputs,
  ...
}:

let
  inherit (config.planet) name;
in
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];

  age = {
    # TODO: don't use the same identity for decryption for all hosts
    identityPaths = [ "/etc/agenix/identity" ];

    rekey = {
      masterIdentities = [ "/etc/agenix/identity" ];
      hostPubkey = builtins.readFile ./ssh/id_ed25519.pub; # TODO: make host-specific
      storageMode = "local";
      localStorageDir = "${toString ../../secrets/_}/${name}";
    };
  };
}
