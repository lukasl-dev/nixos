{
  description = "lukasl-dev";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:nix-community/nixGL";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    catppuccin.url = "github:catppuccin/nix";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    zen-browser.url = "github:MarceColl/zen-browser-flake";

    mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.05";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      nixgl,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          nixgl.overlay
        ];
      };
      specialArgs = {
        inherit inputs pkgs-unstable meta;
      };

      meta = {
        user = {
          name = "lukas";
          fullName = "Lukas Leeb";
        };
        domain = "lukasl.dev";
        git = {
          username = "lukasl-dev";
        };
      };
    in
    {
      nixosConfigurations = {
        vega = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [ ./hosts/desktops/vega ];
        };

        orion = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [ ./hosts/desktops/orion ];
        };

        sirius = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [ ./hosts/servers/sirius ];
        };
      };
    };
}
