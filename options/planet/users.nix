{ config, lib, ... }:

let
  inherit (config.age) secrets;
  inherit (config.planet) user;
in
{
  options.planet = {
    user = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Username of the user.";
        default = "lukas";
        example = "lukas";
      };

      password = lib.mkOption {
        type = lib.types.str;
        description = "Name of the hashed password secret.";
        default = "universe/user/password";
        example = "universe/user/password";
      };

      description = lib.mkOption {
        type = lib.types.str;
        description = "The description of the user, usually the full name.";
        default = "Lukas Leeb";
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

    age.secrets = {
      ${user.password}.rekeyFile = ../../secrets/universe/user/password.age;
    };

    users.users = {
      root = {
        hashedPasswordFile = secrets.${user.password}.path;
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
        hashedPasswordFile = secrets.${user.password}.path;
      };
    };
  };
}
