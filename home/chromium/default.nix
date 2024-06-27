{ pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
      "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1Password
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # DarkReader
      "gppongmhjkpfnbhagpmjfkannfbllamg" # Wappalyzer
      "hkgfoiooedgoejojocmhlaklaeopbecg" # Picture-in-Picture
      "egnjhciaieeiiohknchakcodbpgjnchh" # Tab Wrangler
      "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
      "hlgbcneanomplepojfcnclggenpcoldo" # Perplexity - AI Companion
      "oldceeleldhonbafppcapldpdifcinji" # LanguageTool
    ];  
  };
}
