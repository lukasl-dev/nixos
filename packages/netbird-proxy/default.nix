{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "netbird-proxy";
  version = "0.74.4";

  src = fetchFromGitHub {
    owner = "netbirdio";
    repo = "netbird";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3V9w5/5mhoFHUt4W2epMJeL2O56W9wpbbJd/Edq73HA=";
  };

  vendorHash = "sha256-z/2+LUBocWQ06EfdJ4nujr4vb1e2zjmlufsGgGWN0ak=";

  subPackages = [ "proxy/cmd/proxy" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/netbirdio/netbird/proxy/cmd/proxy/cmd.Version=${finalAttrs.version}"
  ];

  doCheck = false;

  postInstall = ''
    mv "$out/bin/proxy" "$out/bin/netbird-proxy"
  '';

  meta = {
    homepage = "https://netbird.io";
    changelog = "https://github.com/netbirdio/netbird/releases/tag/v${finalAttrs.version}";
    description = "NetBird reverse proxy for public and mesh-private services";
    license = lib.licenses.bsd3;
    mainProgram = "netbird-proxy";
  };
})
