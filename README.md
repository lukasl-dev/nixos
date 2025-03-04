# My NixOS Flake

<div align="center">
    <img src="https://img.shields.io/badge/Uses-Flake-4c72bb?style=for-the-badge&logo=nixos" alt="NixOS" />
    <img src="https://img.shields.io/badge/Desktop-Hyprland-00c0e5?style=for-the-badge&logo=hyprland" alt="Hyprland" />
</div>

<br />

This is my personal [NixOS](https://nixos.org/) configuration for my desktops and servers.

> [!IMPORTANT]
> I do not recommend anyone to use it since it is heavily personalised to my needs. However, the reason I share this repository is to simplify my deployments and allow others, especially new NixOS users, to explore different config structures to choose the best of all worlds.

![Preview](./docs/preview.png)

## Synopsis

After restructuring my config over and over again, I came up with the following structure, which works very well for me at the moment:

```
.
├── docs
│   └── documentation-related files, e.g. screenshots, ...
├── dots
│   └── dotfiles, e.g. Neovim, ghostty, ...
├── home
│   ├── desktop
│   │   └── home-manager config for desktop hosts
│   ├── headless
│   │   └── home-manager config for non-desktop hosts, e.g. servers
│   └── shared config for both desktop and headless hosts
├── hosts
│   ├── desktops
│   │   ├── orion
│   │   │   └── NixOS config for the Orion desktop host
│   │   ├── vega
│   │   │   └── NixOS config for the Vega desktop host
│   │   └── shared config for all desktop hosts
│   ├── servers
│   │   ├── pollux
│   │   │   └── NixOS config for the Pollux server host
│   │   └── shared config for all server hosts
│   └── shared config for both desktop and server hosts
├── modules
│   └── NixOS modules for various services and apps
├── scripts
│   └── useful scripts
├── secrets
│   └── sops secret files
├── wallpapers
│   └── wallpapers used by desktop hosts
```

## Credits

This configuration takes advantage of some other repositories and projects, including:

- [home-manager](https://github.com/nix-community/home-manager)
- [sops](https://github.com/Mic92/sops-nix)
- [hyprland](https://github.com/hyprwm/Hyprland)
- [wallpapers](./wallpapers/README.md)
- [Vimjoyer's Discord community](https://www.youtube.com/@vimjoyer)

