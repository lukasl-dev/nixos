{ config, lib, ... }:

let
  inherit (config.planet) user;
in
{
  options.planet = {
    user = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Username of the user.";
        example = "lukas";
      };

      password = lib.mkOption {
        type = lib.types.path;
        description = "Public SSH key file path. Path values are copied to the Nix store.";
        example = lib.literalExpression "./id_ed25519.pub";
      };

      description = lib.mkOption {
        type = lib.types.str;
        description = "The description of the user, usually the full name.";
        default = "";
        example = "Lukas Leeb";
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = user.name != "";
        message = "🪐 Please define 'planet.user.name'.";
      }
    ];

    users.users = {
      root = {
        hashedPasswordFile = user.password;
      };

      "${user.name}" = {
        isNormalUser = true;
        inherit (user) description;
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
          "libvirtd"
          "libvirt"
          "kvm"
        ];
        hashedPasswordFile = user.password;
      };
    };
  };
}
