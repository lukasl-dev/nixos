{
  description = "lukasl-dev";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";

    hjem.follows = "hjem-rum/hjem";
    hjem-rum = {
      url = "github:snugnug/hjem-rum";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-shell.url = "github:aciceri/agenix-shell";

    jail-nix.url = "sourcehut:~alexdavid/jail.nix";

    catppuccin.url = "github:catppuccin/nix/release-26.05";

    nvf.url = "github:notashelf/nvf";

    fff.url = "github:dmtrKovalenko/fff";

    pi.url = "github:lukasl-dev/pi.nix";
    pi-codex-conversion.url = "github:lukasl-dev/pi-codex-conversion.nix";
    firn = {
      url = "github:lukasl-dev/firn";
      flake = false;
    };

    hermes-agent.url = "github:NousResearch/hermes-agent";

    tuwunel.url = "github:matrix-construct/tuwunel";

    hyprland.url = "github:hyprwm/Hyprland/v0.55.0";

    dms.url = "github:AvengeMedia/DankMaterialShell/stable";
    dgop.url = "github:AvengeMedia/dgop";

    ghostty.url = "github:ghostty-org/ghostty";

    handy.url = "github:cjpais/Handy";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.home-manager.flakeModules.home-manager

        inputs.agenix-rekey.flakeModule
        inputs.agenix-shell.flakeModules.default
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          formatter = pkgs.writeShellScriptBin "nixfmt" ''
            exec ${pkgs.lib.getExe pkgs.nixfmt} --width 80 "$@"
          '';

          devShells = {
            default = pkgs.mkShell {
              packages = [ config.agenix-rekey.package ];
            };
          };

          packages = {
            vim =
              let
                built = inputs.nvf.lib.neovimConfiguration {
                  inherit pkgs;
                  modules = [ ./packages/vim ];
                };
              in
              built.neovim;
          };
        };

      flake.nixosConfigurations =
        let
          atlas = import ./atlas { inherit inputs; };
        in
        {
          vega = atlas.planets.eval {
            planet = ./planets/vega;
          };

          pollux = atlas.planets.eval {
            planet = ./planets/pollux;
          };

          ida = atlas.planets.eval {
            system = "aarch64-linux";
            planet = ./planets/ida;
          };
        };
    };
}
