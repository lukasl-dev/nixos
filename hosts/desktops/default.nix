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
    ../../modules/apps/nautilus.nix
    ../../modules/apps/onepassword.nix
    ../../modules/apps/seahorse.nix
    ../../modules/apps/uxplay.nix

    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/xserver.nix
    ../../modules/desktop/sddm.nix

    ../../modules/gaming/gamemode.nix
    ../../modules/gaming/steam.nix

    ../../modules/graphics/graphics.nix
    ../../modules/graphics/nvidia.nix
    ../../modules/graphics/qt.nix

    ../../modules/sound/pipewire.nix

    ../../modules/bluetooth.nix
    ../../modules/udiskie.nix
  ];

  networking.domain = "hosts.${meta.domain}";

  home-manager.users.${meta.user.name} = lib.mkDefault (
    import ../../home/desktop { inherit inputs pkgs pkgs-unstable; }
  );
}
