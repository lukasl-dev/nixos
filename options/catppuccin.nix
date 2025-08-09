{ inputs, ... }:

let
  catppuccin = {
    enable = true;

    flavor = "mocha";
  };
in
{
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];
  catppuccin = catppuccin;

  universe.hm = [
    {
      imports = [ inputs.catppuccin.homeModules.catppuccin ];
      catppuccin = catppuccin;
    }
  ];
}
