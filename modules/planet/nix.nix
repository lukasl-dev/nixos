{
  inputs,
  config,
  pkgs,
  atlas,
  ...
}:

let
  inherit (config) planet;
  steward = atlas.travellers.eval planet.steward.traveller;
in
{
  documentation.nixos.enable = false;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ steward.user.name ];
      extra-substituters = [
        "https://nix-community.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nix-prefetch-github
    nixd
  ];

  programs.nix-ld.enable = true;
}
