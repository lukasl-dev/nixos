{ inputs, ... }:

let
  catppuccin = {
    enable = true;
    flavor = "mocha";
  };
in
{
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];
  inherit catppuccin;

  planet.hm = [
    {
      imports = [ inputs.catppuccin.homeModules.catppuccin ];
      inherit catppuccin;
    }
  ];
}
