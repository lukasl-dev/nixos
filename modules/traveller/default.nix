{ lib, ... }:

{
  imports = [
    ./desktop
    ./git.nix
    ./jujutsu.nix
    ./keys.nix
    ./ssh.nix
    ./user.nix
  ];

  options.traveller = {
    name = lib.mkOption {
      type = lib.types.str;
    };

    email = lib.mkOption {
      type = lib.types.str;
    };

    modules = lib.mkOption {
      type = lib.types.listOf lib.types.deferredModule;
      default = [ ];
    };
  };
}
