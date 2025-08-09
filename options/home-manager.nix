{
  inputs,
  config,
  lib,
  ...
}:

let
  user = config.universe.user;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.hjem.nixosModules.default
  ];

  options.universe.hm = lib.mkOption {
    type = lib.types.listOf lib.types.attrs;
    default = [ ];
    description = "A list of Home Manager module fragments to be merged together.";
  };

  config = {
    # hjem.users.${user.name} = {
    #   enable = true;
    #   directory = "/home/${user.name}";
    # };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      users.${user.name} = lib.mkMerge config.universe.hm;
    };
  };
}
