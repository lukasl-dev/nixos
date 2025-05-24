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

    ../../modules/apps/localsend.nix
    ../../modules/apps/seahorse.nix
    ../../modules/apps/uxplay.nix
    ../../modules/apps/wireshark.nix

    ../../modules/graphical/display/wayland/hyprland.nix
    ../../modules/graphical/display/x11/xserver.nix
    ../../modules/graphical/desktop/sddm.nix
    ../../modules/graphical/qt.nix

    ../../modules/hardware/gpus/nvidia.nix

    ../../modules/gaming/gamemode.nix
    ../../modules/gaming/steam.nix

    ../../modules/security/polkit.nix
    ../../modules/security/sops.nix

    ../../modules/system/appimage.nix
    ../../modules/system/bluetooth.nix
    ../../modules/system/udiskie.nix
    ../../modules/system/sound/pipewire.nix
  ];

  networking.domain = "hosts.${meta.domain}";

  home-manager.users.${meta.user.name} = lib.mkDefault (
    import ../../home/desktop { inherit inputs pkgs pkgs-unstable; }
  );
}
