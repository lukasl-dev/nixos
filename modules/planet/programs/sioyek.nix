{
  config,
  lib,
  pkgs,
  atlas,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.programs) sioyek;

  wrapped = pkgs.symlinkJoin {
    name = "sioyek";
    paths = [ pkgs.sioyek ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      wrapProgram "$out/bin/sioyek" \
        --set QT_QPA_PLATFORM xcb
    '';

    inherit (pkgs.sioyek) meta;
  };
in
{
  options.planet.programs.sioyek.enable = lib.mkOption {
    type = lib.types.bool;
    default = planet.desktop.enable;
    description = "Enable the Sioyek PDF viewer.";
  };

  config = lib.mkIf sioyek.enable {
    environment.systemPackages = [ wrapped ];

    hjem.users = atlas.travellers.forEach planet (_: {
      xdg.mime-apps.default-applications."application/pdf" = "sioyek.desktop";
    });
  };
}
