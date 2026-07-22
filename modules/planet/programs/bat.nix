{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) catppuccin;
  inherit (catppuccin) flavor;

  theme = "Catppuccin ${lib.toSentenceCase flavor}";
in
{
  environment.systemPackages = [
    (pkgs.symlinkJoin {
      name = "bat-catppuccin-${flavor}";
      paths = [ pkgs.bat ];
      nativeBuildInputs = [ pkgs.makeWrapper ];

      postBuild = ''
        wrapProgram "$out/bin/bat" \
          --set-default BAT_THEME ${lib.escapeShellArg theme}
      '';
    })
  ];
}
