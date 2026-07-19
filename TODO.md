# To Do

- [ ] Remove home manager for faster builds?
- [ ] Improve Nix build/switch performance
    - [ ] Enable distributed builders in `nix.settings.builders`
    - [ ] Set `nix.settings.builders-use-substitutes = true`
    - [ ] Add trusted builder keys and SSH setup
    - [ ] Verify remote builder with `nix build --builders ...`
    - [ ] Measure before/after (`nixos-rebuild --fast` timing)
- [ ] Reduce rebuilds caused by `overrideAttrs`
    - [ ] Find all `overrideAttrs` wrapping desktop apps
    - [ ] Replace wrapper-style overrides with `makeWrapper`/launcher derivations where possible
    - [ ] Keep upstream package derivations cacheable
    - [ ] Rebuild one host and confirm cache hits improve
- [ ] Replace netbird with declarative wireguard
- [ ] Users for homunculus
- [ ] Get rid of universe.nix

