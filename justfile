sd-image planet:
    nix build -L .#nixosConfigurations.{{ planet }}.config.system.build.sdImage
