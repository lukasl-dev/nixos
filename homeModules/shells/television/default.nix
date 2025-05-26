{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  ns = pkgs.writeShellApplication {
    name = "ns";
    runtimeInputs = with pkgs; [
      fzf
      nix-search-tv
    ];
    text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
  };
in
{
  programs.television = {
    enable = true;

    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;

    channels = {
      nix_channels = {
        cable_channel = [
          {
            name = "nixpkgs";
            source_command = "nix-search-tv print";
            preview_command = "nix-search-tv preview {}";
          }
        ];
      };
    };
  };

  home.packages = [
    pkgs-unstable.nix-search-tv
    ns
  ];
}
