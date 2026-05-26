{
  jail,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) display;
  inherit (config.planet.programs) helium;

  version = "0.12.3.1";
  release =
    {
      x86_64-linux = {
        arch = "x86_64";
        hash = "sha256-a4kcudN+bsOV253BSmTFsx0Tngmr/jbUd/A1gesc6QE=";
      };
      aarch64-linux = {
        arch = "arm64";
        hash = "sha256-GN/k/5mkazNPY1TGOGwJVYdM0YR805/2HHVGY6e1+9c=";
      };
    }
    .${pkgs.stdenv.hostPlatform.system}
      or (throw "planet.programs.helium: unsupported system ${pkgs.stdenv.hostPlatform.system}");

  derivation = pkgs.stdenvNoCC.mkDerivation {
    pname = "helium";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-${release.arch}_linux.tar.xz";
      inherit (release) hash;
    };

    sourceRoot = "helium-${version}-${release.arch}_linux";

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = runtimeLibs;

    autoPatchelfIgnoreMissingDeps = [
      "libQt6Core.so.6"
      "libQt6Gui.so.6"
      "libQt6Widgets.so.6"
      "libQt5Core.so.5"
      "libQt5Gui.so.5"
      "libQt5Widgets.so.5"
    ];

    installPhase = # bash
      ''
        runHook preInstall

        mkdir -p $out/bin $out/lib/helium $out/share/applications $out/share/icons/hicolor/256x256/apps
        cp -r . $out/lib/helium

        rm -f $out/lib/helium/libvulkan.so.1
        ln -s ${lib.getLib pkgs.vulkan-loader}/lib/libvulkan.so.1 $out/lib/helium/libvulkan.so.1

        ln -s $out/lib/helium/helium $out/bin/helium
        install -Dm644 helium.desktop $out/share/applications/helium.desktop
        install -Dm644 product_logo_256.png $out/share/icons/hicolor/256x256/apps/helium.png

        runHook postInstall
      '';
  };

  runtimeLibs = with pkgs; [
    glib
    nspr
    nss
    atk
    at-spi2-atk
    dbus
    cups
    expat
    libxcb
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    libxkbcommon
    at-spi2-core
    libgbm
    mesa
    cairo
    pango
    systemd
    alsa-lib
    libGL
    vulkan-loader
    pciutils
  ];

  features = lib.optionalString (display.type == "wayland") "WaylandLinuxDrmSyncobj";

  wrapped = pkgs.symlinkJoin {
    name = "helium";
    paths = [ derivation ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm -f $out/bin/helium
      makeWrapper ${derivation}/bin/helium $out/bin/helium \
        --add-flags "--ozone-platform=${toString display.type}" \
        ${lib.optionalString (features != "") ''--add-flags "--enable-features=${features}"''}
    '';
  };

  jailed = jail "helium" wrapped (
    with jail.combinators;
    [
      network
      gui
      gpu
      (persist-home "helium")
      (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
      camera
      notifications
      (dbus {
        talk = [
          "org.freedesktop.portal.*"
          "org.freedesktop.Notifications"
          "org.mpris.*"
        ];
      })
    ]
  );
in
{
  options.planet.programs = {
    helium = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = display.enable;
        description = "Enable helium browser";
      };

      package = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        default = jailed;
        description = "Package used for Helium browser.";
        example = "jail \"helium\" (pkgs.symlinkJoin { ... }) [...];";
      };
    };
  };

  config = lib.mkIf helium.enable {
    environment.systemPackages = [ helium.package ];

    planet.display.hyprland.lua =
      let
        exe = lib.getExe' helium.package "helium";
      in
      [
        # lua
        ''
          hl.bind("SUPER + B", hl.dsp.exec_cmd("${exe}"))
        ''
      ];
  };
}
