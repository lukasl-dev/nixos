{ inputs }:

let
  atlas = {
    domain = "lukasl.dev";

    planets = import ./planets.nix {
      inherit atlas inputs;
      inherit (inputs.nixpkgs) lib;
    };

    secrets = import ./secrets.nix;

    travellers = import ./travellers.nix {
      inherit atlas;
      inherit (inputs.nixpkgs) lib;
    };
  };
in
atlas
