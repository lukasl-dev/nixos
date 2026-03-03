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
          ];

          hashedPasswordFile = config.sops.secrets."universe/user/password".path;
        };
      };
    };

    # ensure user-owned xdg base directories exist before home manager and
    # secret materialisation touch files below them
    systemd.tmpfiles.rules = [
      "d /home/${user.name}/.config 0700 ${user.name} users - -"
      "d /home/${user.name}/.local 0700 ${user.name} users - -"
      "d /home/${user.name}/.local/cache 0700 ${user.name} users - -"

      # fix ownership/mode if these directories were previously created by root
      "z /home/${user.name}/.config 0700 ${user.name} users - -"
      "z /home/${user.name}/.local 0700 ${user.name} users - -"
      "z /home/${user.name}/.local/cache 0700 ${user.name} users - -"
    ];
  };
}
