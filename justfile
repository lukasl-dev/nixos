available_systems := `nix flake show --json . | jq '.nixosConfigurations | keys'`

default:
    @just --list

[group('flake')]
check:
    nix flake check

[group('flake')]
update:
    nix flake update

[group('flake')]
update-unstable:
    nix flake update nixpkgs-unstable

[group('flake')]
update-stable:
    nix flake update nixpkgs

[group('systems')]
list:
    @echo "{{ available_systems }}"

[group('systems')]
has system:
    @if echo '{{ available_systems }}' | jq --exit-status --arg system "{{ system }}" 'index($system)' > /dev/null; then \
         echo "true"; \
    else \
         echo "false"; \
    fi

[group('systems')]
require system:
    @if ! echo '{{ available_systems }}' | jq --exit-status --arg system "{{ system }}" 'index($system)' > /dev/null; then \
       echo "System {{ system }} not found. Use 'just systems' to list available systems."; \
       exit 1; \
    fi

[group('systems')]
switch system:
    @if ! echo '{{ available_systems }}' | jq --exit-status --arg system "{{ system }}" 'index($system)' > /dev/null; then \
         echo "System {{ system }} not found. Use 'just systems' to list available systems."; \
         exit 1; \
    fi
    nixos-rebuild switch --flake .#{{ system }}

[group('systems')]
build system:
    @if ! echo '{{ available_systems }}' | jq --exit-status --arg system "{{ system }}" 'index($system)' > /dev/null; then \
         echo "System {{ system }} not found. Use 'just systems' to list available systems."; \
         exit 1; \
    fi
    nixos-rebuild build --flake .#{{ system }}

[group('systems')]
diff other:
    nvd diff /run/current-system {{ other }}
