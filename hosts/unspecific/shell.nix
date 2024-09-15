{ inputs, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
  };

  environment.pathsToLink = [ "/share/zsh" ];

  services.nixos-cli = {
    enable = true;
    package = inputs.nixos-cli.packages.${pkgs.system}.nixosLegacy;
  };
}
