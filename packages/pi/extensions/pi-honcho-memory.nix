{ pkgs }:

let
  honchoSdk = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@honcho-ai/sdk/-/sdk-2.0.1.tgz";
    hash = "sha512-y/Wk49C0N1miI9BZTNWFIbzdUkMZfP4Do/EJ1q4lEIK+FAOKxQgces/zET3kPKV3zF9sOUl2pXrFb/XKYayeYw==";
  };
  zod = pkgs.fetchurl {
    url = "https://registry.npmjs.org/zod/-/zod-4.0.0.tgz";
    hash = "sha512-9diLdTPc/L7w/5jI4C3gHYNiGHDV9IZYxo1e5LSD8cabi65WVTWWb+g2BGPEpUUCOxR4D+6O5B0AzyMdUAXwrw==";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "pi-honcho-memory";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "agneym";
    repo = "pi-honcho-memory";
    rev = "d088e7b388def441b7423e0e4990ddc056b60205";
    hash = "sha256-W5NH6FXIV+vfUJKR8rkbt/9ijE1JwOZNWxt78QHTIXg=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p \
      $out/extensions \
      $out/node_modules/@honcho-ai/sdk \
      $out/node_modules/zod

    cp package.json $out/
    cp extensions/*.ts $out/extensions/

    # The extension targets upstream Pi package names. Adapt it to this Pi
    # fork and its TypeBox compatibility package.
    substituteInPlace \
      $out/extensions/client.ts \
      $out/extensions/commands.ts \
      $out/extensions/git.ts \
      $out/extensions/index.ts \
      $out/extensions/session-key.ts \
      $out/extensions/tools.ts \
      --replace-fail '@mariozechner/pi-coding-agent' '@earendil-works/pi-coding-agent'
    substituteInPlace $out/extensions/tools.ts \
      --replace-fail '@mariozechner/pi-ai' '@earendil-works/pi-ai' \
      --replace-fail '@sinclair/typebox' 'typebox'

    # session_start covers startup, new, resume, and fork in the current Pi
    # lifecycle. The two removed hooks belong to an older API.
    sed -i '/  pi.on("session_switch"/,/^  });$/d' $out/extensions/index.ts
    sed -i '/  pi.on("session_fork"/,/^  });$/d' $out/extensions/index.ts

    tar -xzf ${honchoSdk} \
      -C $out/node_modules/@honcho-ai/sdk \
      --strip-components=1
    tar -xzf ${zod} \
      -C $out/node_modules/zod \
      --strip-components=1

    runHook postInstall
  '';
}
