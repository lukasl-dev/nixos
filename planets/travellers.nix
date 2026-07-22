{
  config,
  lib,
  atlas,
  ...
}:

let
  inherit (config) planet;

  roles = [
    "visitor"
    "resident"
    "operator"
  ];

  assignmentOptions = {
    traveller = lib.mkOption {
      type = lib.types.path;
    };

    groups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  eval = assignment: atlas.travellers.eval assignment.traveller;
  steward = eval planet.steward;
in
{
  options.planet = {
    roles = lib.genAttrs roles (_: {
      groups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    });

    steward = lib.mkOption {
      type = lib.types.submodule {
        options = assignmentOptions;
      };
    };

    travellers = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = assignmentOptions // {
            role = lib.mkOption {
              type = lib.types.enum roles;
              default = "visitor";
            };
          };
        }
      );
      default = [ ];
    };
  };

  config.planet.modules =
    lib.concatMap (
      assignment:
      let
        traveller = eval assignment;
      in
      traveller.modules
      ++ [
        {
          users.users.${traveller.user.name}.extraGroups = lib.unique (
            assignment.groups ++ lib.optionals (assignment ? role) planet.roles.${assignment.role}.groups
          );
        }
      ]
    ) ([ planet.steward ] ++ planet.travellers)
    ++ [
      (
        { config, ... }:

        {
          users.users.root = {
            hashedPasswordFile = config.age.secrets.${steward.user.password}.path;
            openssh.authorizedKeys.keys = [ steward.keys.public ];
          };
        }
      )
    ];
}
