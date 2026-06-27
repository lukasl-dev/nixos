{
  inputs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet) user;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  options.planet = {
    hm = lib.mkOption {
      type = lib.types.listOf lib.types.deferredModule;
      default = [ ];
      description = "A list of Home Manager module fragments to be merged together.";
    };
  };

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      backupFileExtension = "backup";

      users =
        let
          module = {
            imports = config.planet.hm;
          };
        in
        {
          root = module;
          ${user.name} = module;
        };
    };
  };
}
