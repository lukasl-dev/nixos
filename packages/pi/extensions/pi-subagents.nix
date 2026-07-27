{ pkgs }:

let
  typebox = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@sinclair/typebox/-/typebox-0.34.52.tgz";
    hash = "sha512-XiMQh7qqVlxZzcVD+kkGMNGMzcTrDMLWI7S4x7z1MkCkbDPrekpZXEUK0eZqZFMuHQg2a2DZOcDIh9o5v3Gonw==";
  };
  croner = pkgs.fetchurl {
    url = "https://registry.npmjs.org/croner/-/croner-10.0.1.tgz";
    hash = "sha512-ixNtAJndqh173VQ4KodSdJEI6nuioBWI0V1ITNKhZZsO0pEMoDxz539T4FTTbSZ/xIOSuDnzxLVRqBVSvPNE2g==";
  };
  nanoid = pkgs.fetchurl {
    url = "https://registry.npmjs.org/nanoid/-/nanoid-5.1.16.tgz";
    hash = "sha512-kVrnsrJqMR8+oLJnGEmSWw9BivK5mt7H3FZatVRjrc5wGqFYuBxX1yG7+A7Gi5AefkX6t/oCkizcQgpu0cY1dQ==";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "pi-subagents";
  version = "0.14.3";
  src = pkgs.fetchFromGitHub {
    owner = "tintinweb";
    repo = "pi-subagents";
    rev = "c10b1836256e760da75296ccd4e57a77ada1325e";
    hash = "sha256-ZztgK9TUrpLsTSmYTOlHu8f6P5G/EA3MmVhqSfFZLQA=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p \
      $out/node_modules/@sinclair/typebox \
      $out/node_modules/croner \
      $out/node_modules/nanoid

    cp package.json $out/
    cp -r src $out/

    tar -xzf ${typebox} -C $out/node_modules/@sinclair/typebox --strip-components=1
    tar -xzf ${croner} -C $out/node_modules/croner --strip-components=1
    tar -xzf ${nanoid} -C $out/node_modules/nanoid --strip-components=1

    runHook postInstall
  '';
}
