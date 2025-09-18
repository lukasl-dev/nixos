{
  description = "lukasl-dev";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";

    # determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien.url = "github:thiagokokada/nix-alien";

    nixgl.url = "github:nix-community/nixGL";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    catppuccin.url = "github:catppuccin/nix";

    catppuccin-where-is-my-sddm-theme.url = "github:catppuccin/where-is-my-sddm-theme";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    ghostty.url = "github:ghostty-org/ghostty";

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tuwunel.url = "github:matrix-construct/tuwunel";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      # determinate,
      systems,
      nvf,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      forEachSystem = nixpkgs.lib.genAttrs (import systems);

      nixosSystem =
        module:
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
            # determinate.nixosModules.default

            ./options
            ./universe.nix
            module
          ];
        };
    in
    {
      nixosConfigurations = {
        orion = nixosSystem ./planets/orion;
        vega = nixosSystem ./planets/vega;
        pollux = nixosSystem ./planets/pollux;
      };

      packages = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          vim =
            (nvf.lib.neovimConfiguration {
              inherit pkgs;
              modules = [ ./vim.nix ];
            }).neovim;
        }
      );
    };
}
