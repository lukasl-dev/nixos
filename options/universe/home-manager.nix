{
  inputs,
  config,
  lib,
  ...
}:

let
  inherit (config.universe) user;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  options.universe.hm = lib.mkOption {
    type = lib.types.listOf lib.types.attrs;
    default = [ ];
    description = "A list of Home Manager module fragments to be merged together.";
  };

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      backupFileExtension = "backup";

      users =
        let
          module = lib.mkMerge config.universe.hm;
        in
        {
          root = module;
          ${user.name} = module;
        };
    };
  };
}
