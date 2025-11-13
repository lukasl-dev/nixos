{ config, lib, ... }:

let
  inherit (config.universe) user;
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
        assertion = user.name != "";
        message = "🪐 Please define 'universe.user.name'.";
      }
    ];

    sops.secrets = {
      "universe/user/password" = {
        neededForUsers = true;
      };
    };

    users = {
      users = {
        root = {
          hashedPasswordFile = config.sops.secrets."universe/user/password".path;
        };

        "${user.name}" = {
          isNormalUser = true;
          inherit (user) description;
          extraGroups = [
            "networkmanager"
            "wheel"
            "docker"
            "wireshark"
            "libvirtd"
            "libvirt"
            "kvm"
            "input"
          ];

          hashedPasswordFile = config.sops.secrets."universe/user/password".path;
        };
      };
    };

    environment.sessionVariables = {
      EDITOR = "nvim";
    };

    # universe.hm = [
    #   {
    #     home = {
    #       username = user.name;
    #       homeDirectory = "/home/${user.name}";
    #     };
    #   }
    # ];
  };
}
