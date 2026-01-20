{
  description = "lukasl-dev";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
    catppuccin.url = "github:catppuccin/nix"; # TODO: fixate /release-25.11 as soon as it is available
    catppuccin-where-is-my-sddm-theme.url = "github:catppuccin/where-is-my-sddm-theme";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    ghostty.url = "github:ghostty-org/ghostty";
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tuwunel.url = "github:matrix-construct/tuwunel";
    fff-nvim.url = "github:dmtrKovalenko/fff.nvim";
    capTUre.url = "github:lukasl-dev/capTUre";
    nur.url = "github:nix-community/NUR";
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      # TODO: resolve issue
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    # codex.url = "github:openai/codex";
    opencode.url = "github:MBanucu/opencode/fix/bun-version-pin";
    rime.url = "github:lukasl-dev/rime";
    outofbounds.url = "github:lukasl-dev/outofbounds";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      systems,
      nvf,
      ...
    }@inputs:
    let
      defaultSystem = "x86_64-linux";

      forEachSystem = nixpkgs.lib.genAttrs (import systems);

      mkSpecialArgs =
        system:
        let
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;

            config = {
              allowUnfree = true;
            };
          };
        in
        {
          inherit self inputs pkgs-unstable;
        };

      mkNixosSystem =
        {
          system ? defaultSystem,
          module ? null,
          modules ? [ ],
        }:
        let
          baseModules = [
            ./options
            ./universe.nix
          ];
          extraModules = (if module != null then [ module ] else [ ]) ++ modules;
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = mkSpecialArgs system;
          modules = baseModules ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        orion = mkNixosSystem { module = ./planets/orion; };
        vega = mkNixosSystem { module = ./planets/vega; };
        pollux = mkNixosSystem { module = ./planets/pollux; };

        ida = mkNixosSystem {
          system = "aarch64-linux";
          module = ./planets/ida;
        };
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
              modules = [ ./packages/vim ];
              extraSpecialArgs = {
                rinputs = inputs;
              };
            }).neovim;
        }
      );
    };
}
