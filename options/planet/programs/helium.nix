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

  heliumVersion = "0.9.3.1";
  heliumRelease =
    {
      x86_64-linux = {
        arch = "x86_64";
        hash = "sha256-4c7tIra7SriBQe3ii4bLFTV1chLPQSNdOWNUR6dxfP0=";
      };
      aarch64-linux = {
        arch = "arm64";
        hash = "sha256-ejqK6b/s3rENo29q1ivpQDcuaYWrSjVJp8H8iY0gn+8=";
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
  ];
in
{
  options.planet.programs.helium = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable helium browser";
    };
  };

  config = lib.mkIf helium.enable {
    environment.systemPackages = [
      (pkgs.symlinkJoin {
        name = "helium";
        paths = [ heliumPackage ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/helium \
            --prefix LD_LIBRARY_PATH : "$out/lib/helium" \
            --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}" \
            --add-flags "--ozone-platform=x11" \
            --add-flags "--use-angle=vulkan" \
            --add-flags "--enable-features=Vulkan,VulkanFromANGLE${lib.optionalString hyprland.enable ",WaylandLinuxDrmSyncobj"}"
            # --add-flags "--enable-unsafe-webgpu" \
        '';
      })
    ];
  };
}
