{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) wm;
  inherit (wm) hyprland;
  inherit (config.planet.programs) helium;
in
{
  options.planet.programs.helium = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable helium browser";
    };
  };

  config = lib.mkIf helium.enable {
    universe.hm = [
      {
        programs.chromium = {
          enable = true;
          package = pkgs.nur.repos.Ev357.helium;
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
