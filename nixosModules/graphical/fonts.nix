{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.space-mono

      helvetica-neue-lt-std
      geist-font
    ];
  };
}
