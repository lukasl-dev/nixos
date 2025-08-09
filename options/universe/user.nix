{ config, lib, ... }:

let
  universe = config.universe;

  user = universe.user;
in
{
  options.universe.user = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Username of the user.";
      example = "lukas";
    };

    description = lib.mkOption {
      type = lib.types.str;
      description = "The description of the user, usually the full name.";
      default = "";
      example = "Lukas Leeb";
    };
  };

  config = {
    assertions = [
      {
        assertion = universe.user.name != "";
        message = "🪐 Please define 'universe.user.name'.";
      }
    ];

    sops.secrets = {
      "universe/user/password" = {
        neededForUsers = true;
      };

      "universe/user/ssh/private_key" = {
        owner = user.name;
        path = "/home/${user.name}/.ssh/id_ed25519";
      };
    };

    users = {
      users = {
        root = {
          hashedPasswordFile = config.sops.secrets."universe/user/password".path;
        };

        "${user.name}" = {
          isNormalUser = true;
          description = user.description;
          extraGroups = [
            "networkmanager"
            "wheel"
            "docker"
            "wireshark"
          ];

          hashedPasswordFile = config.sops.secrets."universe/user/password".path;
        };
      };
    };

    universe.hm = [
      {
        home = {
          username = user.name;
          homeDirectory = "/home/${user.name}";
        };
      }
    ];
  };
}
