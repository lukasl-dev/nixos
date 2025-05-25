{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  hypr-nixpkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  hypr-pkgs = inputs.hyprland.packages.${pkgs-unstable.stdenv.hostPlatform.system};

  hyprland = hypr-pkgs.hyprland;
  xdg-desktop-portal-hyprland = hypr-pkgs.xdg-desktop-portal-hyprland;
in
{
  imports = [ ../../../nixos/caches/hyprland.nix ];

  programs.hyprland = {
    enable = true;

    package = hyprland;
    portalPackage = xdg-desktop-portal-hyprland;

    xwayland.enable = true;
    withUWSM = false;
  };

  environment = {
    sessionVariables = {
      # hint electron apps to use ozone wayland platform
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";

      # prefer wayland over X11 for GTK apps
      GDK_BACKEND = "wayland,x11";

      # prefer wayland over xcb for QT apps
      QT_QPA_PLATFORM = "wayland;xcb";

      # fix reparenting issues with Java apps
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };

    systemPackages = [
      pkgs-unstable.egl-wayland
      pkgs-unstable.wl-clipboard

      pkgs-unstable.hyprcursor
      pkgs.catppuccin-cursors.mochaMauve

      pkgs.grim
      pkgs.slurp
      pkgs.hyprshot
    ];
  };

  hardware.graphics = {
    package = hypr-nixpkgs.mesa;

    enable32Bit = true;
    package32 = hypr-nixpkgs.pkgsi686Linux.mesa;

    extraPackages = [ hypr-nixpkgs.rocmPackages.clr ];
  };

  # xdg.portal = {
  #   config = {
  #     hyprland.default = [
  #       "gtk"
  #       "hyprland"
  #     ];
  #   };
  #   extraPortals = [ xdg-desktop-portal-hyprland ];
  # };
}
