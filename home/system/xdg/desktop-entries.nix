{ lib, config, pkgs, ... }:

{
  xdg.desktopEntries = {

    sioyek = lib.mkIf config.programs.sioyek.enable {
      name = "Sioyek";
      genericName = "PDF Viewer";
      comment = "A PDF viewer designed for reading research papers and technical books";
      exec = ''${pkgs.sioyek}/bin/sioyek'';
      icon = "sioyek";
      categories = [ "Office" "Viewer" ];
      type = "Application";
    };

    # ranger = lib.mkIf config.programs.ranger.enable {
    #   name = "Ranger";
    #   genericName = "File Manager";
    #   comment = "A console file manager with VI key bindings";
    #   exec = ''${pkgs.ranger}/bin/ranger'';
    #   icon = "ranger";
    #   categories = [ "System" "FileTools" ];
    #   type = "Application"; 
    #   terminal = true;
    # };

  };
}
