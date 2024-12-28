{
  config,
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  # programs.kitty = {
  #   enable = true;
  #
  #   package = pkgs-unstable.kitty;
  #
  #   font = {
  #     name = "SpaceMono";
  #     size = 12;
  #   };
  #
  #   extraConfig = ''
  #     window_padding_width 8
  #     confirm_os_window_close 0
  #     enable_audio_bell no
  #   '';
  # };

  # ghostty
  home.file.".config/ghostty" = {
    enable = true;
    source = ../../dots/ghostty;
    target = ".config/ghostty";
  };

  programs.sioyek.enable = true;

  programs.gpg.enable = true;

  services.easyeffects.enable = true;

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
    # zen browser
    inputs.zen-browser.packages."${pkgs.system}".default

    # nyxt browser
    pkgs.nyxt

    # messengers
    pkgs.zapzap
    pkgs.signal-desktop
    pkgs-unstable.vesktop
    pkgs.slack

    # obsidian
    pkgs-unstable.obsidian

    # anki learn cards
    pkgs-unstable.anki

    # slicers
    # pkgs-unstable.bambu-studio

    # bitwarden
    pkgs-unstable.bitwarden
    pkgs-unstable.bitwarden-cli

    pkgs-unstable.wireshark

    pkgs-unstable.calcure

    # youtube music
    pkgs-unstable.youtube-music
    pkgs-unstable.youtube-tui

    # ghostty
    inputs.ghostty.packages.x86_64-linux.default
  ];

  # nyxt config directory
  home.file.".config/nyxt" = {
    enable = true;
    source = ../../dots/nyxt;
    target = ".config/nyxt";
  };
}
