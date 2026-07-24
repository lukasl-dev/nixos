{
  atlas,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (pkgs.stdenv.hostPlatform) system;

  lua = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system}.lua5_5;
  toLua = lib.generators.toLua { };

  upstream = inputs.hyprland.packages.${system}.hyprland;
in
{
  imports = [
    inputs.hyprland.nixosModules.default

    ./autostart.nix
    ./config.nix
    ./cursor.nix
    ./dank.nix
    ./mesa.nix
    ./monitors.nix
    ./polkit.nix
    ./uwsm.nix
  ];

  options.planet.desktop.hyprland.lua = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "Planet-specific Hyprland Lua configuration.";
  };

  config = lib.mkIf planet.desktop.enable {
    nix.settings = {
      extra-substituters = [ "https://hyprland.cachix.org" ];
      extra-trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    programs.hyprland = {
      enable = true;
      package = upstream.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.git ];
        cmakeFlags = (old.cmakeFlags or [ ]) ++ [
          "-DNO_HYPRPM=ON"

          # Hyprland's upstream desktop file uses `Exec=uwsm ...`, which
          # DankGreeter cannot find uwsm when launching that entry. Let NixOS
          # provide a session with an absolute uwsm path instead.
          "-DNO_UWSM=ON"
        ];
        passthru = (old.passthru or { }) // {
          providedSessions = [ "hyprland" ];
        };
      });
      xwayland.enable = true;
    };

    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

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
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";

        GDK_BACKEND = "wayland,x11";

        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

        _JAVA_AWT_WM_NONREPARENTING = "1";

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

    hjem.users = atlas.travellers.forEach planet (
      traveller:
      let
        planetConfig = planet.desktop.hyprland.config;
        travellerConfig = traveller.desktop.hyprland.config;
        hyprlandConfig = lib.recursiveUpdate planetConfig travellerConfig;

        merged = lib.concatStringsSep "\n\n" (
          lib.filter (lua: lua != "") [
            (lib.optionalString (
              hyprlandConfig != { }
            ) "hl.config(${toLua hyprlandConfig})")
            planet.desktop.hyprland.lua
            traveller.desktop.hyprland.lua
          ]
        );

        checked =
          let
            key = "hyprland-${planet.name}-${traveller.name}";
            source = pkgs.writeText "${key}.lua" merged;
            name = "${key}-config.lua";
          in
          pkgs.runCommand name { } ''
            cp ${source} "$out"

            # Hyprland 0.55's verifier currently crashes for Lua configurations.
            ${lib.getExe' lua "luac"} -p "$out"
          '';
      in
      {
        xdg.config.files = {
          "hypr/hyprland.lua".source = checked;
        }
        // lib.optionalAttrs planet.hardware.nvidia.enable {
          "hypr/xdph.conf".text = ''
            screencopy {
              force_shm = 1
            }
          '';
        };
      }
    );
  };
}
