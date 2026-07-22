{
  agenix-rekey,
  pkgs,
  ...
}:

pkgs.writeShellApplication {
  name = "planet-keygen";

  runtimeInputs = [
    agenix-rekey
    pkgs.coreutils
    pkgs.gitMinimal
    pkgs.openssh
  ];

  text = # bash
    ''
      usage() {
        echo "Usage: planet-keygen PLANET"
      }

      die() {
        echo "planet-keygen: $*" >&2
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

      planet="$1"
      root="$(git rev-parse --show-toplevel 2>/dev/null)" \
        || die "run this command inside the universe repository"
      [[ -d "$root/planets/$planet" ]] || die "unknown planet: $planet"

      sudo=/run/wrappers/bin/sudo
      [[ -x "$sudo" ]] || die "NixOS sudo wrapper not found"

      keys="$root/secrets/planets/$planet/keys"
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

      temporary="$(mktemp -d)"
      trap 'rm -rf "$temporary"' EXIT

      "$sudo" "$agenix" view "$private" | cat > "$temporary/private"
      chmod 0600 "$temporary/private"

      key="$(ssh-keygen -y -f "$temporary/private")"
      printf '%s %s@%s\n' "$key" "$USER" "$planet" > "$temporary/public"
      install -m 0644 "$temporary/public" "$public"

      git add "$private" "$public"

      echo "Wrote $private"
      echo "Wrote $public"
      echo "Run 'sudo agenix rekey --add-to-git' after all source secrets exist."
    '';
}
