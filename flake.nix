{
  description = "lukasl-dev";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixos-cli.url = "github:water-sucks/nixos";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    catppuccin.url = "github:catppuccin/nix";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    zen-browser.url = "github:MarceColl/zen-browser-flake";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-ld,
      catppuccin,
      # nixos-cli,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        vega = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs pkgs-unstable;
          };
          modules = [
            ./hosts/unspecific
            ./hosts/vega

            home-manager.nixosModules.home-manager

            catppuccin.nixosModules.catppuccin
            nix-ld.nixosModules.nix-ld
            # nixos-cli.nixosModules.nixos-cli
          ];
        };
      };
    };
}
