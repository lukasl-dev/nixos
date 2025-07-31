available_systems := `nix-shell -p jq --run "nix flake show --json . | jq '.nixosConfigurations | keys'"`

default:
    @just --list

list:
    @echo '{{ available_systems }}' | nix-shell -p jq --run "jq --raw-output .[]"

switch:
    nix-shell -p nh --run "nh os switch"

build:
    nix-shell -p nh --run "nh os build"

clean:
    nix-shell -p nh --run "nh clean"
