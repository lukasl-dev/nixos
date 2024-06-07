{ inputs, outputs, ... }:

{
  imports = [
    inputs.ags.homeManagerModules.default
    inputs.hyprland.homeManagerModules.default

    ./packages.nix

    ./1password
    ./alacritty
    ./chromium
    ./nx-ld
    ./nvim
    ./shell
    ./virtualisation
    ./wayland
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.local
        inputs.nur.overlay
        inputs.nixneovimplugins.overlays.default
    ];
  };

  home = {
    username = "lukas";
    homeDirectory = "/home/lukas";
    stateVersion = "24.05";
  };
}
