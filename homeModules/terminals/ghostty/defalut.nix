{ inputs, ... }:

{
  home = {
    packages = [ inputs.ghostty.packages.x86_64-linux.default ];

    file.".config/ghostty" = {
      enable = true;
      source = ./;
      target = ".config/ghostty";
    };
  };
}
