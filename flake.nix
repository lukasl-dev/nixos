{
  description = "lukasl-dev";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
    nvf = {
      url = "github:notashelf/nvf";
      # url = "github:notashelf/nvf?ref=v0.8";
      # inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.55.0";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    catppuccin.url = "github:catppuccin/nix/release-26.05";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    ghostty.url = "github:ghostty-org/ghostty";
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tuwunel.url = "github:matrix-construct/tuwunel";
    capTUre.url = "github:lukasl-dev/capTUre";
    nur.url = "github:nix-community/NUR";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pi.url = "github:lukasl-dev/pi.nix";
    pi-codex-conversion = {
      url = "github:lukasl-dev/pi-codex-conversion.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firn = {
      url = "github:lukasl-dev/firn";
      flake = false;
    };
    rime.url = "github:lukasl-dev/rime";
    outofbounds.url = "github:lukasl-dev/outofbounds";
    fff = {
      url = "github:dmtrKovalenko/fff";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lightpanda.url = "github:lukasl-dev/browser";
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      systems,
      nvf,
      jail-nix,
      ...
    }@inputs:
    let
      defaultSystem = "x86_64-linux";

      forEachSystem = nixpkgs.lib.genAttrs (import systems);

      overlays = import ./overlays {
        inherit inputs;
        lib = nixpkgs.lib;
      };

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ overlays.default ];
          config.allowUnfree = true;
        };

      mkNixosSystem =
        {
          system ? defaultSystem,
          module,
        }:
        let
          baseModules = [
            ./options
            ./universe.nix
            { nixpkgs.overlays = [ overlays.default ]; }
          ];
          extraModules = [ module ];

          pkgs = pkgsFor system;
          jail = jail-nix.lib.init pkgs;
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self inputs jail;
          };
          modules = baseModules ++ extraModules;
        };
    in
    {
      inherit overlays;

      agenix-rekey = inputs.agenix-rekey.configure {
        userFlake = self;
        inherit (self) nixosConfigurations;
        darwinConfigurations = { };
      };

      nixosConfigurations = {
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
          pkgs = pkgsFor system;
        in
        {
          helium = pkgs.callPackage ./packages/helium { };
          upterm = pkgs.callPackage ./packages/upterm { };

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

      devShells = forEachSystem (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages =
              with pkgs;
              [
                just
                jq
              ]
              ++ [
                inputs.agenix-rekey.packages.${system}.default
                inputs.nixos-anywhere.packages.${system}.default
                pkgs.nh
              ]
              ++ (import ./packages/scripts { inherit pkgs; });

            shellHook = ''
              repo_root=$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null || printf '%s\n' "$PWD")
              bash ${./options/planet/programs/pi/extensions/setup-node-modules.sh} \
                "$repo_root" \
                ${inputs.pi.packages.${system}.coding-agent}
            '';
          };
        }
      );

      formatter = forEachSystem (
        system:
        let
          pkgs = pkgsFor system;
        in
        pkgs.nixfmt
      );
    };
}
