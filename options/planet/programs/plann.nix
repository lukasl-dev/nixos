{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy) domain;
  inherit (config.planet) user;

  password = "galaxy/cal/accounts/lukas";
  configFile = "galaxy/cal/plann";

  package = pkgs.symlinkJoin {
    name = "plann-configured-${pkgs.plann.version}";
    paths = [ pkgs.plann ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/plann" \
        --add-flags "--config-file ${age.secrets.${configFile}.path}"
    '';
  };
in
{
  options.planet.programs.plann = {
    package = lib.mkOption {
      type = lib.types.package;
      default = package;
      readOnly = true;
      description = "Configured plann package.";
    };

    configFile = lib.mkOption {
      type = lib.types.str;
      default = age.secrets.${configFile}.path;
      readOnly = true;
      description = "Path to plann's generated CalDAV configuration.";
    };
  };

  config = {
    age.secrets.${configFile} = {
      rekeyFile = ../../../secrets/galaxy/cal/plann.age;
      owner = user.name;
      group = "plann";
      mode = "0440";
      generator = {
        dependencies.password = age.secrets.${password};
        script =
          {
            decrypt,
            deps,
            pkgs,
            ...
          }:
          ''
            password="$(${decrypt} "${deps.password.file}")"
            ${lib.getExe pkgs.jq} -n \
              --arg url "https://cal.${domain}" \
              --arg username ${lib.escapeShellArg user.name} \
              --arg password "$password" \
              '{default: {caldav_url: $url, caldav_user: $username, caldav_pass: $password}}'
          '';
      };
    };

    users.groups.plann = { };
    users.users.${user.name}.extraGroups = [ "plann" ];

    environment.systemPackages = [ package ];
  };
}
