{
  self,
  config,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;

  package = self.packages.${system}.upterm;
  server = "ssh://term.${config.universe.domain}:2222";

  wrapped = pkgs.symlinkJoin {
    name = "upterm-wrapped-${package.version}";
    paths = [ package ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/upterm" \
        --set TERM xterm-256color \
        --set UPTERM_SERVER "${server}"
    '';
  };
in
{
  environment.systemPackages = [ wrapped ];
}
