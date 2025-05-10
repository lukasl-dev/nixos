{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  programs.chromium = {
    enable = true;
    package = pkgs-unstable.brave;
    extensions = [
      "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
      "khgocmkkpikpnmmkgmdnfckapcdkgfaf" # 1Password
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
    commandLineArgs = [
      "--enable-features=WaylandLinuxDrmSyncobj"
    ];
  };

  programs.firefox = {
    enable = true;
    package = pkgs-unstable.firefox;

    profiles.default = {
      isDefault = true;
    };
  };

  home.packages = [
    inputs.zen-browser.packages."${pkgs.system}".default
    pkgs-unstable.vivaldi
  ];
}
