{
  fff,
  pkgs,
}:

pkgs.buildNpmPackage {
  pname = "pi-fff";
  version = "0.7.2";
  src = fff.source;
  npmDepsHash = "sha256-+uk57NmH4I3mHIdNE4xfSPilwWefni5B51jVxxS3OD0=";
  npmInstallFlags = [ "--include=optional" ];
  npmRebuildFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;

  buildPhase = ''
    runHook preBuild

    npm run build --workspace packages/fff-node

    mkdir -p packages/fff-node/bin
    cp ${fff.package}/lib/libfff_c.so packages/fff-node/bin/

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p \
      $out/packages \
      $out/target/release \
      $out/node_modules \
      $out/node_modules/@ff-labs \
      $out/node_modules/@yuuang

    cp -r packages/pi-fff $out/packages/
    cp -r packages/fff-node $out/packages/
    cp -r node_modules/ffi-rs $out/node_modules/
    cp -r node_modules/@yuuang/* $out/node_modules/@yuuang/
    ln -s ../../packages/fff-node $out/node_modules/@ff-labs/fff-node

    cp packages/fff-node/bin/libfff_c.so $out/target/release/
    touch $out/Cargo.toml

    runHook postInstall
  '';
}
