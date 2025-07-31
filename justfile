available_systems := `nix-shell -p jq --run "nix flake show --json . | jq '.nixosConfigurations | keys'"`
flake := "~/nixos"

default:
    @just --list

list:
    @echo '{{ available_systems }}' | nix-shell -p jq --run "jq --raw-output .[]"

switch:
    nix-shell -p nh --run "nh os switch {{ flake }}"

build:
    nix-shell -p nh --run "nh os build {{ flake }}"

clean:
    nix-shell -p nh --run "nh clean"
