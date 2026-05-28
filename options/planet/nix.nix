{

  config,
  inputs,
  pkgs,
  ...
}:

let
  inherit (config.planet) user hardware;
in
{
  documentation.nixos.enable = false;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        user.name
      ];
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

  nixpkgs =
    let
      config = {
        allowUnfree = true;
        cudaSupport = hardware.nvidia.cuda;
      };
    in
    {
      inherit config;
    };

  environment.systemPackages = with pkgs; [
    nix-prefetch-github
    nixd
  ];

  planet.hm = [
    {
      home.sessionPath = [ "$HOME/.local/bin" ];
    }
  ];
}
