{
  description = "lukasl-dev";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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

    nix-alien.url = "github:thiagokokada/nix-alien";
    nixgl.url = "github:nix-community/nixGL";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    catppuccin.url = "github:catppuccin/nix";
    catppuccin-where-is-my-sddm-theme.url = "github:catppuccin/where-is-my-sddm-theme";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    ghostty.url = "github:ghostty-org/ghostty";

    hjem.url = "github:feel-co/hjem";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      nixosSystem =
        module: overrideMeta:
        let
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;

            config = {
              allowUnfree = true;
            };
          };
          specialArgs = {
            inherit inputs pkgs-unstable;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = specialArgs;
          modules = [
            ./options
            ./universe.nix
            module
          ];
        };
    in
    {
      nixosConfigurations = {
        vega = nixosSystem ./planets/vega { };
      };
    };
}
