{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) catppuccin;

  theme = "catppuccin_${catppuccin.flavor}.theme";
  settings = pkgs.writeText "btop-${catppuccin.flavor}.conf" ''
    color_theme = "${theme}"
  '';
in
{
  environment.systemPackages = [
    (pkgs.symlinkJoin {
      name = "btop-catppuccin-${catppuccin.flavor}";
      paths = [ pkgs.btop ];
      nativeBuildInputs = [ pkgs.makeWrapper ];

      postBuild = ''
        wrapProgram "$out/bin/btop" \
          --add-flags "--config ${lib.escapeShellArg settings}" \
          --add-flags "--themes-dir ${lib.escapeShellArg catppuccin.sources.btop}"
      '';
    })
  ];
}
