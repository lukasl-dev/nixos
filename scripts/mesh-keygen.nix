{
  agenix-rekey,
  pkgs,
  ...
}:

pkgs.writeShellApplication {
  name = "mesh-keygen";

  runtimeInputs = [
    agenix-rekey
    pkgs.coreutils
    pkgs.gitMinimal
    pkgs.wireguard-tools
  ];

  text = # bash
    ''
      usage() {
        echo "Usage: mesh-keygen PLANET"
      }

      die() {
        echo "mesh-keygen: $*" >&2
        exit 1
      }

      [[ "''${1:-}" != "-h" && "''${1:-}" != "--help" ]] || {
        usage
        exit 0
      }
      [[ $# == 1 ]] || {
        usage >&2
        exit 2
      }
      (( EUID != 0 )) || die "run this command without sudo"

      name="$1"
      root="$(git rev-parse --show-toplevel 2>/dev/null)" \
        || die "run this command inside the universe repository"
      [[ -d "$root/planets/$name" ]] || die "unknown planet: $name"

      sudo=/run/wrappers/bin/sudo
      [[ -x "$sudo" ]] || die "NixOS sudo wrapper not found"

      keys="$root/secrets/planets/$name/mesh"
      private="$keys/private.age"
      public="$keys/public.pub"
      agenix=${pkgs.lib.escapeShellArg (pkgs.lib.getExe agenix-rekey)}

      cd "$root"
      mkdir -p "$keys"
      chmod 0700 "$keys"

      if [[ ! -e "$private" ]]; then
        "$sudo" "$agenix" generate "$private"
        "$sudo" chown "$(id -u):$(id -g)" "$private"
      fi

      "$sudo" "$agenix" view "$private" \
        | wg pubkey \
        | install -m 0644 /dev/stdin "$public"

      git add "$private" "$public"

      echo "Wrote $private"
      echo "Wrote $public"
      echo "Run 'sudo agenix rekey --add-to-git' after all mesh keys exist."
    '';
}
