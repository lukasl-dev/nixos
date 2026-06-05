{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet.display) hyprland;
  inherit (config.planet.hardware) nvidia;
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  imports = [
    inputs.hyprland.nixosModules.default

    ./animation.nix
    ./autoStart.nix
    ./bind.nix
    ./config.nix
    ./cursors.nix
    ./dank.nix
    ./events.nix
    ./mesa.nix
    ./monitors.nix
    # ./noctalia.nix
    ./polkit.nix
    ./screenshot.nix
  ];

  options.planet.display = {
    hyprland = {
      enable = lib.mkEnableOption "Enable Hyprland";

      lua = lib.mkOption {
        type = lib.types.listOf lib.types.lines;
        default = [ ];
        example = [
          # lua
          ''
            local x = "hello"
            print(x)
          ''
        ];
        description = "Lua snippets to include in the generated Hyprland Lua config.";
      };
    };
  };

  config = lib.mkIf hyprland.enable {
    nix.settings = {
      extra-substituters = [ "https://hyprland.cachix.org" ];
      extra-trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    programs.hyprland = {
      enable = true;

      package = inputs.hyprland.packages.${system}.hyprland.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.git ];
        cmakeFlags = (old.cmakeFlags or [ ]) ++ [
          "-DNO_HYPRPM=ON"

          # Hyprland's upstream desktop file uses `Exec=uwsm ...`, which
          # DankGreeter currently launches without a PATH containing uwsm.  Let
          # the NixOS UWSM module provide the session instead; it uses an
          # absolute uwsm path.
          "-DNO_UWSM=ON"
        ];
      });

      xwayland.enable = true;
      withUWSM = true;
    };

    # Hyprland 0.55 warns when launched directly instead of through its
    # watchdog wrapper. The NixOS Hyprland module's generated UWSM session uses
    # `/run/current-system/sw/bin/Hyprland`; override it to the wrapper.
    programs.uwsm.waylandCompositors.hyprland.binPath = lib.mkForce "/run/current-system/sw/bin/start-hyprland";

    # UWSM enables dbus-broker by default. Keep the existing dbus-daemon
    # implementation to avoid activation failures while switching live systems.
    services.dbus.implementation = lib.mkForce "dbus";

    # Add GTK portal for OpenURI, file chooser, etc.
    # Don't set xdg.portal.config - let configPackages from Hyprland handle it
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    # On NVIDIA, xdph's DMA-BUF screencopy path can negotiate successfully while
    # Chromium/Electron consumers still receive black frames. Force the portal to
    # offer SHM buffers for WebRTC screen sharing instead.
    planet.hm = lib.mkIf nvidia.enable [
      {
        xdg.configFile."hypr/xdph.conf".text = ''
          screencopy {
            force_shm = 1
          }
        '';
      }
    ];

    programs.dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          gtk-theme = "Adwaita";
          icon-theme = "Flat-Remix-Red-Dark";
          font-name = "Noto Sans Medium 11";
          document-font-name = "Noto Sans Medium 11";
          monospace-font-name = "Noto Sans Mono Medium 11";
        };
      }
    ];

    environment = {
      etc."xdg/hypr/hyprland.lua".text = lib.concatStringsSep "\n\n" hyprland.lua;

      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";

        GDK_BACKEND = "wayland,x11";

        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

        _JAVA_AWT_WM_NONREPARENTING = "1";

        NVD_BACKEND = "direct";

        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
      };

      systemPackages = with pkgs; [
        wl-clipboard
        libnotify
        wev
        evtest
      ];
    };
  };
}
