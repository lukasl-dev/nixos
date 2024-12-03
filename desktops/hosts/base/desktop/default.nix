{ inputs, pkgs-unstable, ... }:

{
  imports = [ ../unspecific ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs pkgs-unstable;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  catppuccin = {
    enable = true;

    flavor = "mocha";
  };
}
