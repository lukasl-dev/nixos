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
      catppuccin = catppuccin // {
        # The catppuccin module still targets the renamed
        # `programs.gemini-cli` option on 26.05.
        gemini-cli.enable = false;
      };
    }
  ];
}
