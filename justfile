sd-image planet:
    nix build -L .#nixosConfigurations.{{ planet }}.config.system.build.sdImage

# Show commit messages between the flake.lock in HEAD and the working flake.lock
# for a given input name. Works best for GitHub inputs; otherwise prints revs.
flake-changes input:
	./scripts/flake-changes.sh {{ input }}
