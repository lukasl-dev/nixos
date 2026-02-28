{
  pkgs,
  config,
  ...
}:

let
  inherit (config.universe) domain user;
in
{
  environment.systemPackages = [ pkgs.unstable.ntfy-sh ];

  age.secrets = {
    "universe/ntfy/user" = {
      rekeyFile = ../../../secrets/universe/ntfy/user.age;
      intermediary = true;
    };
    "universe/ntfy/password" = {
      rekeyFile = ../../../secrets/universe/ntfy/password.age;
      intermediary = true;
    };

    "universe/ntfy/client" = {
      rekeyFile = ../../../secrets/universe/ntfy/client.age;
      generator = {
        dependencies = {
          username = config.age.secrets."universe/ntfy/user";
          password = config.age.secrets."universe/ntfy/password";
        };
        script =
          { decrypt, deps, ... }:
          ''
            username="$(${decrypt} "${deps.username.file}")"
            password="$(${decrypt} "${deps.password.file}")"

            cat <<EOF
            default-host: https://ntfy.${domain}
            default-user: $username
            default-password: $password
            EOF
          '';
      };
      owner = user.name;
      path = "/home/${user.name}/.config/ntfy/client.yml";
    };
  };
}
