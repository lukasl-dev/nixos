# nixos

## Meta Configuration

This repository contains few constants that are used in the configuration of the NixOS system. To prevent duplication, they are passed to all modules (home-manager and NixOS) as an argument called `meta`.

```nix
meta = {
    user = {
      name = "lukas";
      fullName = "Lukas Leeb";
    };
    git = {
      username = "lukasl-dev";
    };
    domain = "lukasl.dev";
};
```

