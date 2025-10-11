{
  config,
  pkgs-unstable,
  lib,
  ...
}:

{
  options.planet.development.lean = {
    enable = lib.mkEnableOption "Enable lean";
  };

  config = lib.mkIf config.planet.development.lean.enable {
    environment.systemPackages = with pkgs-unstable; [
      # lean4
      elan
      (pkgs.writeShellApplication {
        name = "mathlib-new";
        runtimeInputs = [ pkgs.elan ];
        text = ''
          set -euo pipefail
          if [ $# -lt 1 ]; then
            echo "usage: $0 <dir> [extra lake args...]" >&2
            exit 2
          fi
          dir="$1"; shift
          lake +leanprover-community/mathlib4:lean-toolchain new "$dir" math "$@"
        '';
      })
    ];
  };
}
