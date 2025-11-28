sd-image planet:
    nix build -L .#nixosConfigurations.{{ planet }}.config.system.build.sdImage

flake-changes input:
    ./scripts/flake-changes.sh {{ input }}

switch:
    ./scripts/safe-switch.sh
