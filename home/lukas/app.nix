{
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}:

{
  # pdf viewer
  programs.sioyek.enable = true;

  # gpg key manager
  programs.gpg.enable = true;

  # audio effects
  services.easyeffects.enable = true;

  # brave browser
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
      "pljfkbaipkidhmaljaaakibigbcmmpnc" # Atom Material Icons
    ];
    # commandLineArgs = [
    #   "--enable-features=UseOzonePlatform"
    #   "--ozone-platform=x11"
    # ];
  };

  programs.firefox = {
    enable = true;
    package = pkgs-unstable.firefox;

    profiles.default = {
      isDefault = true;
    };
  };

  home.packages = [
    # zen browser
    inputs.zen-browser.packages."${pkgs.system}".default

    pkgs.nyxt

    # discord
    pkgs-unstable.vesktop
    pkgs-unstable.discord
    pkgs-unstable.discordo

    pkgs.signal-desktop
    pkgs.slack
    pkgs-unstable.obsidian
    pkgs-unstable.zoom
    pkgs-unstable.anki

    # jetbrains
    pkgs-unstable.jetbrains.idea-ultimate
  ];

  home.file.".config/nyxt" = {
    enable = true;
    source = ../../dots/nyxt;
    target = ".config/nyxt";
  };
}
