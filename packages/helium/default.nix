{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  vulkan-loader,
  glib,
  nspr,
  nss,
  atk,
  at-spi2-atk,
  dbus,
  cups,
  expat,
  libxcb,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxkbcommon,
  at-spi2-core,
  libgbm,
  mesa,
  cairo,
  pango,
  systemd,
  alsa-lib,
  libpulseaudio,
  pipewire,
  libGL,
  libdrm,
  libva,
  libsecret,
  wayland,
  pciutils,
}:

let
  version = "0.12.5.1";
  releases = {
    x86_64-linux = {
      arch = "x86_64";
      hash = "sha256-tfiy1MkxXq9vOjp57R3ykHjleG0Viz/C2ttwXbHnPwA=";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256-q6cCrvDh9eYQZwCLArKXZDpYkl0Zzi2g9gp9l+G+QIA=";
    };
  };
  release =
    releases.${stdenvNoCC.hostPlatform.system}
      or (throw "helium: unsupported system ${stdenvNoCC.hostPlatform.system}");

  runtimeLibs = [
    glib
    nspr
    nss
    atk
    at-spi2-atk
    dbus
    cups
    expat
    libxcb
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxkbcommon
    at-spi2-core
    libgbm
    mesa
    cairo
    pango
    systemd
    alsa-lib
    libpulseaudio
    pipewire
    libGL
    libdrm
    libva
    libsecret
    vulkan-loader
    wayland
    pciutils
  ];
in
stdenvNoCC.mkDerivation {
  pname = "helium";
  inherit version;

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-${release.arch}_linux.tar.xz";
    inherit (release) hash;
  };

  sourceRoot = "helium-${version}-${release.arch}_linux";

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = runtimeLibs;

  # Helium ships optional Qt shims for desktop integration. They are loaded
  # opportunistically, so do not make the browser package drag both Qt stacks
  # into the closure just to satisfy autoPatchelf.
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
      ln -s ${lib.getLib vulkan-loader}/lib/libvulkan.so.1 $out/lib/helium/libvulkan.so.1

      ln -s ../lib/helium/helium-wrapper $out/bin/helium
      install -Dm644 helium.desktop $out/share/applications/helium.desktop
      install -Dm644 product_logo_256.png $out/share/icons/hicolor/256x256/apps/helium.png

      runHook postInstall
    '';

  passthru = {
    inherit runtimeLibs;
  };

  meta = {
    description = "Chromium-based web browser without Google services/dependencies";
    homepage = "https://github.com/imputnet/helium-linux";
    mainProgram = "helium";
    platforms = builtins.attrNames releases;
  };
}
