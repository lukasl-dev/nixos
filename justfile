default:
    @just --list

vega-vm-clean:
    rm -rf ./nixos.qcow2

vega-vm-build:
    nixos-rebuild build-vm --flake .#vega

vega-vm-run:
    ./result/bin/run-nixos-vm

vega-vm: vega-vm-clean vega-vm-build vega-vm-run

vega-iso:
    nix build .#nixosConfigurations.vega.config.system.build.isoImage

vega-switch:
    nixos-rebuild switch --flake .#vega
