{ inputs, pkgs-unstable, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs pkgs-unstable;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
