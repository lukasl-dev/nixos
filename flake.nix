{
  description = "lukasl-dev";

  nixConfig = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    lean-nvim = {
      url = "github:Julian/lean.nvim/904dcc2787effac5e0394a46e78499b2c094a3df";
      flake = false;
    };
    vim-tptp = {
      url = "github:c-cube/vim-tptp/c8a010e8d1bbc7e0341346f6b8611d0f3849aaff";
      flake = false;
    };
    vimtex = {
      url = "github:lervag/vimtex/df8892993c1df79b96c2d237c8a0cbcbf72131da";
      flake = false;
    };

    fff.url = "github:dmtrKovalenko/fff";

    pi.url = "github:lukasl-dev/pi.nix";
    pi-codex-conversion.url = "github:lukasl-dev/pi-codex-conversion.nix";
    firn = {
      url = "github:lukasl-dev/firn";
      flake = false;
    };

    herdr.url = "github:ogulcancelik/herdr";

    hermes-agent.url = "github:NousResearch/hermes-agent/v2026.7.20";

    tuwunel.url = "github:matrix-construct/tuwunel";

    hyprland.url = "github:hyprwm/Hyprland/v0.55.0";

    dms.url = "github:AvengeMedia/DankMaterialShell/stable";
    dgop.url = "github:AvengeMedia/dgop";

    ghostty.url = "github:ghostty-org/ghostty";

    handy.url = "github:cjpais/Handy";

    helium.url = "github:schembriaiden/helium-browser-nix-flake";
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      ...
    }:
    let
      overlays = import ./overlays {
        inherit inputs;
        inherit (nixpkgs) lib;
      };

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ overlays.default ];
          config.allowUnfree = true;
        };

      jailFor = system: inputs.jail-nix.lib.init (pkgsFor system);

      atlas = import ./atlas {
        inherit inputs overlays;
      };

      evalPlanet =
        {
          system ? "x86_64-linux",
          planet,
        }:
        atlas.planets.eval {
          inherit planet system;
          specialArgs = {
            jail = jailFor system;
          };
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
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
        let
          planetKeygen = pkgs.callPackage ./scripts/planet-keygen.nix {
            agenix-rekey = config.agenix-rekey.package;
          };
          planetInstallIdentity = pkgs.callPackage ./scripts/planet-install-identity.nix {
            agenix-rekey = config.agenix-rekey.package;
          };
          meshKeygen = pkgs.callPackage ./scripts/mesh-keygen.nix {
            agenix-rekey = config.agenix-rekey.package;
          };
          travellerKeygen = pkgs.callPackage ./scripts/traveller-keygen.nix {
            agenix-rekey = config.agenix-rekey.package;
          };
        in
        {
          _module.args.pkgs = pkgsFor system;

          apps = {
            mesh-keygen = {
              type = "app";
              program = pkgs.lib.getExe meshKeygen;
              meta.description = "Generate a planet's WireGuard mesh identity";
            };
            planet-keygen = {
              type = "app";
              program = pkgs.lib.getExe planetKeygen;
              meta.description = "Generate a planet's SSH identity";
            };
            planet-install-identity = {
              type = "app";
              program = pkgs.lib.getExe planetInstallIdentity;
              meta.description = "Install a planet's deployment identity";
            };
            traveller-keygen = {
              type = "app";
              program = pkgs.lib.getExe travellerKeygen;
              meta.description = "Generate a traveller's SSH identity";
            };
          };

          formatter = pkgs.writeShellScriptBin "nixfmt" ''
            exec ${pkgs.lib.getExe pkgs.nixfmt} --width 80 "$@"
          '';

          devShells = {
            default = pkgs.mkShell {
              packages = [
                config.agenix-rekey.package
                meshKeygen
                planetInstallIdentity
                planetKeygen
                travellerKeygen
              ];
            };
          };

          packages = {
            pi =
              let
                built = inputs.pi.lib.mkCodingAgent {
                  inherit pkgs;
                  modules = [
                    ./packages/pi
                    {
                      _module.args = {
                        fff = {
                          package = inputs'.fff.packages.default;
                          source = inputs.fff.outPath;
                        };
                        pi-codex-conversion = inputs'.pi-codex-conversion.packages.default;
                      };
                    }
                  ];
                };
              in
              built.package;

            vim =
              let
                built = inputs.nvf.lib.neovimConfiguration {
                  inherit pkgs;
                  modules = [
                    ./packages/vim
                    {
                      _module.args = {
                        fff = inputs'.fff.packages.fff-nvim;
                        lean = inputs.lean-nvim;
                        tptp = inputs.vim-tptp;
                        inherit (inputs) vimtex;
                      };
                    }
                  ];
                };
              in
              built.neovim;
          };
        };

      flake = {
        inherit overlays;

        nixosConfigurations = {
          vega = evalPlanet {
            planet = ./planets/vega;
          };

          pollux = evalPlanet {
            planet = ./planets/pollux;
          };

          mizar = evalPlanet {
            planet = ./planets/mizar;
          };

          ida = evalPlanet {
            system = "aarch64-linux";
            planet = ./planets/ida;
          };
        };
      };
    };
}
