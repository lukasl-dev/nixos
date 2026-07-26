# unixverse

<div align="center">
    <img src="https://img.shields.io/badge/Uses-Flake-4c72bb?style=for-the-badge&logo=nixos" alt="NixOS" />
    <img src="https://img.shields.io/badge/Desktop-Hyprland-00c0e5?style=for-the-badge&logo=hyprland" alt="Hyprland" />
</div>

<br />

This is my personal [NixOS](https://nixos.org/) configuration for desktops and
servers.

> [!IMPORTANT]
> I do not recommend using this configuration directly. It is highly
> personalised to my requirements.
>
> **Why publish it?**
>
> 1. A public repository simplifies device installation and deployment.
> 2. Public Nix configurations provide implementation examples for other (new) users.

## Atlas

`atlas/` defines shared topology, global values, and evaluation helpers.

## Module

`modules/` contains reusable planet and traveller modules.

### Planet

A planet is a NixOS machine. `planets/<name>/` contains its hardware, services,
networking, and traveller assignments.

Roles are cumulative:

```text
visitor ⊆ resident ⊆ operator ⊆ steward
```

### Traveller

A traveller is portable user configuration. `travellers/<name>/` defines its
identity, programs, shell, and desktop preferences.

