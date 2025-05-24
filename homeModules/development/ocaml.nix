{ config, pkgs-unstable, ... }:

{
  programs.opam = {
    enable = true;

    enableZshIntegration = config.programs.zsh.enable;
    enableBashIntegration = config.programs.bash.enable;
  };

  home.packages = with pkgs-unstable; [
    ocaml
    ocamlPackages.lsp
    ocamlPackages.ocamlformat
    ocamlPackages.utop
  ];
}
