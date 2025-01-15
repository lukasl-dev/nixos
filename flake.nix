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
    nix-alien.url = "github:thiagokokada/nix-alien";
    nixgl.url = "github:nix-community/nixGL";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    catppuccin.url = "github:catppuccin/nix";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    zen-browser.url = "github:MarceColl/zen-browser-flake";

    ghostty.url = "github:ghostty-org/ghostty";

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
        inherit inputs pkgs-unstable;
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
        time = {
          zone = "Europe/Vienna";
        };
      };
    in
    {
      nixosConfigurations = {
        vega = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = specialArgs // {
            meta = meta // {
              hypr = {
                monitors = [
                  "HDMI-A-1, 1920x1080@239.96, 0x0, 1"
                ];
              };
            };
          };
          modules = [ ./hosts/desktops/vega ];
        };

        # orion = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   specialArgs = specialArgs // {
        #     inherit meta;
        #     # TODO: add monitor explicitly
        #   };
        #   modules = [ ./hosts/desktops/orion ];
        # };

        sirius = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = specialArgs // {
            inherit meta;
          };
          modules = [ ./hosts/servers/sirius ];
        };
      };
    };
}
