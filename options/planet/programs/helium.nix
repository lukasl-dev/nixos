{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) wm;
  inherit (wm) hyprland;
  inherit (config.planet.programs) helium;

  mkOzoneFlag =
    display:
    {
      x11 = "--ozone-platform=x11";
      wayland = "--ozone-platform=wayland";
    }
    .${display};

  mkHeliumFeatures =
    {
      display,
      webgpu ? false,
    }:
    builtins.concatStringsSep "," (
      lib.optionals webgpu [ "Vulkan" "VulkanFromANGLE" "DefaultANGLEVulkan" ]
      ++ lib.optionals (hyprland.enable && display == "wayland") [ "WaylandLinuxDrmSyncobj" ]
    );

  heliumVersion = "0.11.2.1";
  heliumRelease =
    {
      x86_64-linux = {
        arch = "x86_64";
        hash = "sha256-7m4j0r1yQP5n2ww/+947ffR/PlcZPgvT29SyBo/qzZw=";
      };
      aarch64-linux = {
        arch = "arm64";
        hash = "sha256-dfKBzPn3O8kZRDzPrcK64Uf0gO9KiuQM5QMR/G2uyJs=";
      };
    }
    .${pkgs.stdenv.hostPlatform.system}
      or (throw "planet.programs.helium: unsupported system ${pkgs.stdenv.hostPlatform.system}");

  heliumPackage = pkgs.stdenvNoCC.mkDerivation {
    pname = "helium";
    version = heliumVersion;

    src = pkgs.fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/${heliumVersion}/helium-${heliumVersion}-${heliumRelease.arch}_linux.tar.xz";
      inherit (heliumRelease) hash;
    };

    sourceRoot = "helium-${heliumVersion}-${heliumRelease.arch}_linux";

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

  runtimeLibraries = with pkgs; [
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

  mkWrappedHeliumPackage =
    {
      name,
      binName ? name,
      display,
      webgpu ? false,
    }:
    let
      heliumFeatures = mkHeliumFeatures {
        inherit display webgpu;
      };

      wrapperArgs = [
        ''--prefix LD_LIBRARY_PATH : "$out/lib/helium"''
        ''--suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}"''
        ''--add-flags "${mkOzoneFlag display}"''
      ]
      ++ lib.optionals (heliumFeatures != "") [ ''--add-flags "--enable-features=${heliumFeatures}"'' ]
      ++ lib.optionals webgpu [
        ''--add-flags "--use-angle=vulkan"''
        ''--add-flags "--ignore-gpu-blocklist"''
        ''--add-flags "--enable-unsafe-webgpu"''
      ];
    in
    pkgs.symlinkJoin {
      inherit name;
      paths = [ heliumPackage ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        rm -f $out/bin/helium
        makeWrapper ${heliumPackage}/bin/helium $out/bin/${binName} \
          ${lib.concatStringsSep " \\\n          " wrapperArgs}
      '';
    };

  heliumWaylandPackage = mkWrappedHeliumPackage {
    name = "helium";
    binName = "helium";
    display = wm.display;
  };

  heliumWebgpuPackage = pkgs.writeShellScriptBin "helium-webgpu" ''
    export LD_LIBRARY_PATH="${heliumPackage}/lib/helium:${lib.makeLibraryPath runtimeLibraries}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    exec ${heliumPackage}/bin/helium \
      --ozone-platform=x11 \
      --use-angle=vulkan \
      --enable-features=${mkHeliumFeatures { display = "x11"; webgpu = true; }} \
      --ignore-gpu-blocklist \
      --enable-unsafe-webgpu \
      "$@"
  '';
in
{
  options.planet.programs.helium = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable helium browser";
    };

    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = heliumWaylandPackage;
      description = "Package used for Helium browser.";
      example = "pkgs.symlinkJoin { ... }";
    };
  };

  config = lib.mkIf helium.enable {
    environment.systemPackages = [
      helium.package
      heliumWebgpuPackage
    ];

    planet.wm.hyprland.bindings = [
      {
        type = "exec";
        keys = [ "B" ];
        command = lib.getExe' helium.package "helium";
      }
    ];
  };
}
