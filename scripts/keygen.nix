{
  agenix-rekey,
  command,
  entity,
  entityRoot,
  privateRoot,
  publicRelative,
  publicRoot,
  pkgs,
}:

pkgs.writeShellApplication {
  name = command;

  runtimeInputs = [
    agenix-rekey
    pkgs.coreutils
    pkgs.gitMinimal
    pkgs.openssh
  ];

  text = # bash
    ''
      usage() {
        echo "Usage: ${command} ${pkgs.lib.toUpper entity}"
      }

      die() {
        echo "${command}: $*" >&2
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
      [[ -d "$root/${entityRoot}/$name" ]] || die "unknown ${entity}: $name"

      sudo=/run/wrappers/bin/sudo
      [[ -x "$sudo" ]] || die "NixOS sudo wrapper not found"

      keys="$root/${privateRoot}/$name/keys"
      private="$keys/private.age"
      public="$root/${publicRoot}/$name/${publicRelative}"
      agenix=${pkgs.lib.escapeShellArg (pkgs.lib.getExe agenix-rekey)}

      cd "$root"
      mkdir -p "$keys" "$(dirname "$public")"
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
      printf '%s %s@%s\n' "$key" "$USER" "$name" > "$temporary/public"
      install -m 0644 "$temporary/public" "$public"

      git add "$private" "$public"

      echo "Wrote $private"
      echo "Wrote $public"
      echo "Run 'sudo agenix rekey --add-to-git' after all source secrets exist."
    '';
}
