{
  meta,
  inputs,
  pkgs-unstable,
  ...
}:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs pkgs-unstable meta;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
