# nixos

<div align="center">
    <img src="https://img.shields.io/badge/Uses-Flake-4c72bb?style=for-the-badge&logo=nixos" alt="NixOS" />
    <img src="https://img.shields.io/badge/Desktop-Hyprland-00c0e5?style=for-the-badge&logo=hyprland" alt="Hyprland" />
</div>

<br />

This is my personal [NixOS](https://nixos.org/) configuration for my desktops and servers.

> [!IMPORTANT]
> I do not recommend anyone to use it, given that it is highly personalised to my
> own needs.
>
> **Why publishing?**
>
> 1. Making this repository public allows me to setup devices easier since I
>    don't need to manage credentials.
> 2. Public Nix configs allows new users to get inspired by different ideas
>    and configuration methods.

## Terminology

### Planet

The term "planet" refers to a single node in my "universe" (cluster) with its own
set of rules, e.g. `hardware-configuration`, custom services, etc.

### Universe

The term "universe" refers to the cluster of nodes. The universes comprises
universal rules, like shell aliases, users, domain, etc.

## Synopsis

```
.
├──. dns
│  └── dns records configured via dnscontrol
├──. options
│  ├── universe
│  │   └── universal configuration applied to all hosts
│  └── planets
│      └── host-specific configuration that needs to be toggled
├──. planets
│  └── host-specific entry configurations
├──. secrets
│  └── encrypted sops-nix secrets
├──. wallpapers
│  └── wallpapers that are randomly chosen on desktops
└── universe.nix
   └── universally applied values, like username, domain, etc.
```

## Credits

This configuration takes advantage of some other repositories and projects, including:

- [home-manager](https://github.com/nix-community/home-manager)
- [sops-nix](https://github.com/Mic92/sops-nix)
- [hyprland](https://github.com/hyprwm/Hyprland)
- [catppuccin](https://github.com/catppuccin/nix)
- [wallpapers](./wallpapers/README.md)
- [Vimjoyer's Discord community](https://www.youtube.com/@vimjoyer)
