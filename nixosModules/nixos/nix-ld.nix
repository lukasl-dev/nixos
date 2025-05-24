{ inputs, ... }:

{
  imports = [ inputs.nix-ld.nixosModules.nix-ld ];

  programs.nix-ld = {
    enable = true;
    dev.enable = false;
  };
}
