{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  wm = config.planet.wm;
  hyprland = wm.hyprland;
in
{
  options.planet.programs.brave = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable brave";
    };
  };

  config = lib.mkIf config.planet.programs.brave.enable {
    universe.hm = [
      {
        programs.chromium = {
          enable = true;
          package = pkgs-unstable.brave;
          extensions = [
            "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
            "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
            "eimadpbcbfnmbkopoojfekhnkhdbieeh" # DarkReader
            "gppongmhjkpfnbhagpmjfkannfbllamg" # Wappalyzer
            "hkgfoiooedgoejojocmhlaklaeopbecg" # Picture-in-Picture
            "egnjhciaieeiiohknchakcodbpgjnchh" # Tab Wrangler
            "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
            "oldceeleldhonbafppcapldpdifcinji" # LanguageTool
            "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
            "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
            "iiikidmnimlpahbeknmkeonmemajpccj" # Button Stealer
            "cimpffimgeipdhnhjohpbehjkcdpjolg" # Watch2Gether
            "pljfkbaipkidhmaljaaakibigbcmmpnc" # Atom Material Icons
            "ncpjnjohbcgocheijdaafoidjnkpajka" # Tags for Google Calendar
          ];
          commandLineArgs = lib.mkIf hyprland.enable [ "--enable-features=WaylandLinuxDrmSyncobj" ];
        };
      }
    ];
  };
}
