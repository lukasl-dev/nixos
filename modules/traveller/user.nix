{
  config,
  lib,
  atlas,
  ...
}:

let
  inherit (config) traveller;
in
{
  options.traveller.user = {
    name = lib.mkOption {
      type = lib.types.str;
    };

    description = lib.mkOption {
      type = lib.types.str;
    };

    password = lib.mkOption {
      type = lib.types.str;
      default = atlas.secrets.universe [
        "travellers"
        traveller.name
        "user"
        "password"
      ];
      readOnly = true;
      internal = true;
    };
  };

  config.traveller.modules = [
    (
      { config, ... }:

      let
        inherit (config) age;
      in
      {
        age.secrets.${traveller.user.password} = {
          rekeyFile = ../.. + "/secrets/${traveller.user.password}.age";
        };

        users.users.${traveller.user.name} = {
          isNormalUser = true;
          inherit (traveller.user) description;
          hashedPasswordFile = age.secrets.${traveller.user.password}.path;
        };
      }
    )
  ];
}
