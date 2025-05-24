{
  description = "lukasl-dev";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
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
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    ghostty.url = "github:ghostty-org/ghostty";
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

      nixosSystem =
        module: overrideMeta:
        let
          updatedMeta = (import ./meta.nix) // overrideMeta;
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;

            config = {
              allowUnfree = true;
              cudaSupport = updatedMeta.cuda;
            };

            overlays = [ nixgl.overlay ];
          };
          specialArgs = {
            inherit inputs pkgs-unstable;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = specialArgs // {
            meta = updatedMeta;
          };
          modules = [ module ];
        };
    in
    {
      nixosConfigurations = {
        vega = nixosSystem ./machine/hosts/vega/nixos {
          hostName = "vega";
          cuda = true;
          hypr = {
            monitors = [
              "DP-2, 1920x1080@239.96, 0x0, 1"
              "HDMI-A-1, 1920x1080@74.973, 1920x0, 1"
            ];
          };
        };

        # orion = nixosSystem ./hosts/desktops/orion {
        #   hostName = "orion";
        #   hypr = {
        #     monitors = [ "eDP-1, 1920x1080@144.02800, 0x0, 1" ];
        #   };
        # };

        # pollux = nixosSystem ./hosts/servers/pollux {
        #   hostName = "sirius";
        # };
      };
    };
}
