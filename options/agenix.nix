{
  config,
  inputs,
  ...
}:

let
  inherit (config.universe) user;
  inherit (config.planet) name;
in
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];

  # fileSystems."/home/${user.name}/.ssh".neededForBoot = true;

  age = {
    # TODO: don't use the same identity for decryption for all hosts
    identityPaths = [ "/etc/agenix/identity" ];

    rekey = {
      masterIdentities = [ "/etc/agenix/identity" ];
      hostPubkey = builtins.readFile ./universe/ssh/id_ed25519.pub; # TODO: make host-specific
      storageMode = "local";
      localStorageDir = "${toString ../secrets/_}/${name}";
    };
  };
}
