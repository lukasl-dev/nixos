{ ... }:

{
  imports = [
    ../../../presets/desktop/home

    ../../../homeModules/development/go.nix
    ../../../homeModules/development/java.nix
    ../../../homeModules/development/javascript.nix

    ../../../homeModules/editors/jetbrains/idea-ultimate.nix

    ../../../homeModules/gaming/bottles.nix
    ../../../homeModules/gaming/gamescope.nix
    ../../../homeModules/gaming/lutris.nix
    ../../../homeModules/gaming/prismlauncher.nix
    ../../../homeModules/gaming/protonplus.nix
    ../../../homeModules/gaming/protonup-qt.nix
    ../../../homeModules/gaming/r2modman.nix
  ];
}
