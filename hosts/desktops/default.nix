{
  meta,
  lib,
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  imports = [
    ../default.nix

    ../../nixosModules/apps/localsend.nix
    ../../nixosModules/apps/seahorse.nix
    ../../nixosModules/apps/uxplay.nix
    ../../nixosModules/apps/wireshark.nix

    ../../nixosModules/graphical/display/wayland/hyprland.nix
    ../../nixosModules/graphical/display/x11/xserver.nix
    ../../nixosModules/graphical/desktop/sddm.nix
    ../../nixosModules/graphical/qt.nix

    ../../nixosModules/hardware/gpus/nvidia.nix

    ../../nixosModules/gaming/gamemode.nix
    ../../nixosModules/gaming/steam.nix

    ../../nixosModules/security/polkit.nix
    ../../nixosModules/security/sops.nix

    ../../nixosModules/system/appimage.nix
    ../../nixosModules/system/bluetooth.nix
    ../../nixosModules/system/udiskie.nix
    ../../nixosModules/system/sound/pipewire.nix
  ];

  networking.domain = "hosts.${meta.domain}";

  home-manager.users.${meta.user.name} = lib.mkDefault (
    import ../../home/desktop { inherit inputs pkgs pkgs-unstable; }
  );
}
