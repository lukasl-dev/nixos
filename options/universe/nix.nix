{

  config,
  inputs,
  pkgs,
  ...
}:

let
  inherit (config.planet.hardware) nvidia;
in
{
  documentation.nixos.enable = false;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      config.universe.user.name
    ];
  };

  nixpkgs =
    let
      config = {
        allowUnfree = true;
        cudaSupport = nvidia.cuda;
      };
    in
    {
      inherit config;
      overlays = [
        inputs.nur.overlays.default
        inputs.HyprQuickFrame.overlays.default
        (final: _prev: {
          unstable = import inputs.nixpkgs-unstable {
            inherit (final.stdenv.hostPlatform) system;
            inherit config;
          };
        })
      ];
    };

  environment.systemPackages = with pkgs; [
    nix-prefetch-github
  ];
}
