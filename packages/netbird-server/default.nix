{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "netbird-server";
  version = "0.70.5";

  src = fetchFromGitHub {
    owner = "netbirdio";
    repo = "netbird";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AsM+MEeBqxnwD1jE8ocI93tF3l/7s+s5nF073ZMAi/Y=";
  };

  vendorHash = "sha256-ebhjN6o/519ayxWTcscNinKuiL3LSPmE2VNgSitxj5g=";

  subPackages = [ "combined" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/netbirdio/netbird/version.version=${finalAttrs.version}"
    "-X main.builtBy=nix"
  ];

  # Upstream tests need network access and external services.
  doCheck = false;

  postInstall = ''
    mv $out/bin/combined $out/bin/netbird-server
  '';

  meta = {
    homepage = "https://netbird.io";
    changelog = "https://github.com/netbirdio/netbird/releases/tag/v${finalAttrs.version}";
    description = "Combined NetBird self-hosted server (management, signal, relay, and STUN)";
    license = lib.licenses.bsd3;
    mainProgram = "netbird-server";
  };
})
