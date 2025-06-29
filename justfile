available_systems := `nix-shell -p jq --run "nix flake show --json . | jq '.nixosConfigurations | keys'"`

default:
    @just --list

[group('flake')]
check:
    @echo "--> Checking flake..."
    @{ nix flake check 1>/dev/null; } 2>&1 | nix-shell -p pv --run "pv"

[group('flake')]
update:
    @echo "--> Updating all flake inputs..."
    @{ nix flake update 1>/dev/null; } 2>&1 | nix-shell -p pv --run "pv"

[group('flake')]
update-input input:
    @echo "--> Updating flake input '{{ input }}'..."
    @{ nix flake update {{ input }} 1>/dev/null; } 2>&1 | nix-shell -p pv --run "pv"

[group('flake')]
update-unstable:
    @just update-input nixpkgs-unstable

[group('flake')]
update-stable:
    @just update-input nixpkgs

[group('systems')]
list:
    @echo "Available NixOS configurations in this flake:"
    @echo '{{ available_systems }}' | nix-shell -p jq --run "jq --raw-output .[]"

[group('systems')]
has system:
    @if echo '{{ available_systems }}' | nix-shell -p jq --run "jq --exit-status --arg system '{{ system }}' 'any(. == \$system)'" > /dev/null; then \
        echo "true"; \
    else \
        echo "false"; \
    fi

[group('systems')]
require system:
    @if ! echo '{{ available_systems }}' | nix-shell -p jq --run "jq --exit-status --arg system '{{ system }}' 'any(. == \$system)'" > /dev/null; then \
       echo "Error: System '{{ system }}' not found in flake. Use 'just systems list' to see available systems."; \
       exit 1; \
    fi

[group('systems')]
switch system:
    @just require '{{ system }}'
    @just build '{{ system }}'
    @echo "--> Activating new system configuration '{{ system }}'..."
    @sudo ./result/bin/switch-to-configuration switch
    @echo "--> Switch complete."

[group('systems')]
build system:
    @just require '{{ system }}'
    @echo "--> Building system '{{ system }}'..."
    @{ nixos-rebuild build --flake .#{{ system }} --fast 1>/dev/null; } 2>&1 | nix-shell -p pv --run "pv"

[group('systems')]
diff other:
    @just require '{{ other }}'
    @echo "--> Diffing current system against flake configuration '{{ other }}'..."
    @# `nvd` is provided by a nix-shell to diff system generations.
    nix-shell -p nvd --run "nvd diff /run/current-system .#{{ other }}"
