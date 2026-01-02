sd-image planet:
    nix build -L .#nixosConfigurations.{{ planet }}.config.system.build.sdImage

flake-changes input:
    ./scripts/flake-changes.sh {{ input }}

switch:
    ./scripts/safe-switch.sh

cache:
    nix-store -qR --include-outputs $(nix-store -qd /run/current-system) | xargs nix run nixpkgs#attic-client -- push universe
