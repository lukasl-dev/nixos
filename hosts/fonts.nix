{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
          "SpaceMono"
        ];
      })
      helvetica-neue-lt-std
      geist-font
    ];
  };
}
