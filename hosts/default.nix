{ inputs, pkgs-unstable, ... }:

{
  import = [
    inputs.home-manager.nixosModules.home-manager
    inputs.catppuccin.nixosModules.catppuccin
    inputs.nix-ld.nixosModules.nix-ld

    ./i18n.nix
    ./firewall.nix
    ./shell.nix
    ./users.nix
  ];

  system.stateVersion = "24.05";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "lukas"
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

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

  programs.nix-ld.dev.enable = true;
}
