{ pkgs-unstable, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs-unstable.brave;
    extensions = [
      "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
      "khgocmkkpikpnmmkgmdnfckapcdkgfaf" # 1Password
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
    ];  
  };
}
