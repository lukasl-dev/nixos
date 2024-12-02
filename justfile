default:
    @just --list

flake-update:
    nix flake update

vega-vm-clean:
    rm -rf ./nixos.qcow2

vega-vm-build:
    nixos-rebuild build-vm --flake .#vega

vega-vm-run:
    ./result/bin/run-vega-vm

vega-vm: vega-vm-clean vega-vm-build vega-vm-run

vega-iso:
    nix build .#nixosConfigurations.vega.config.system.build.isoImage

vega-switch:
    nixos-rebuild switch --flake .#vega

sirius-vm-clean:
    rm -rf ./nixos.qcow2

sirius-vm-build:
    nixos-rebuild build-vm --flake .#sirius

sirius-vm-run:
    ./result/bin/run-sirius-vm

sirius-vm: sirius-vm-clean sirius-vm-build sirius-vm-run

sirius-iso:
    nix build .#nixosConfigurations.sirius.config.system.build.isoImage

sirius-switch:
    nixos-rebuild switch --flake .#sirius
