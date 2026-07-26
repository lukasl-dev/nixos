{
  agenix-rekey,
  pkgs,
}:

pkgs.writeShellApplication {
  name = "planet-install-identity";

  runtimeInputs = [
    agenix-rekey
    pkgs.coreutils
    pkgs.gawk
    pkgs.gitMinimal
    pkgs.openssh
  ];

  text = # bash
    ''
      usage() {
        cat <<'EOF'
      Usage: planet-install-identity PLANET [HOST] [PORT] [USER]

      Decrypt and install a planet's deployment identity.

      Defaults:
        HOST  PLANET.local
        PORT  2222
        USER  lukas

      Example:
        planet-install-identity ida
        planet-install-identity pollux pollux.lukasl.dev 2222
      EOF
      }

      die() {
        echo "planet-install-identity: $*" >&2
        exit 1
      }

      if [[ "''${1:-}" == "-h" || "''${1:-}" == "--help" ]]; then
        usage
        exit 0
      fi

      if (( $# < 1 || $# > 4 )); then
        usage >&2
        exit 2
      fi

      planet="$1"
      host="''${2:-$planet.local}"
      port="''${3:-2222}"
      user="''${4:-lukas}"

      [[ "$planet" =~ ^[a-zA-Z0-9_-]+$ ]] \
        || die "invalid planet name: $planet"
      [[ "$port" =~ ^[0-9]+$ ]] || die "invalid SSH port: $port"
      [[ "$user" =~ ^[a-zA-Z0-9_-]+$ ]] \
        || die "invalid SSH user: $user"
      (( EUID != 0 )) || die "run this command without sudo"

      repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" \
        || die "run this command inside the universe repository"
      [[ -d "$repo_root/planets/$planet" ]] || die "unknown planet: $planet"
      cd "$repo_root"

      sudo=/run/wrappers/bin/sudo
      [[ -x "$sudo" ]] || die "NixOS sudo wrapper not found"
      agenix=${pkgs.lib.escapeShellArg (pkgs.lib.getExe agenix-rekey)}

      source="secrets/planets/$planet/keys/private.age"
      public="secrets/planets/$planet/keys/public.pub"
      remote_tmp="/tmp/$planet-agenix-identity.$$"

      for file in "$source" "$public"; do
        if [[ ! -f "$file" ]]; then
          echo "Missing identity file: $file" >&2
          exit 1
        fi
      done

      identity="$(mktemp)"
      trap 'rm -f "$identity"' EXIT
      chmod 600 "$identity"

      echo "Decrypting $planet's deployment identity..."
      # The invoking user intentionally owns the temporary output file.
      # shellcheck disable=SC2024
      "$sudo" "$agenix" view "$source" >"$identity"

      expected_fingerprint="$(
        ssh-keygen -lf "$public" | awk '{ print $2 }'
      )"
      actual_fingerprint="$(
        ssh-keygen -lf "$identity" | awk '{ print $2 }'
      )"

      if [[ "$actual_fingerprint" != "$expected_fingerprint" ]]; then
        echo "Decrypted identity does not match $public" >&2
        exit 1
      fi

      ssh_options=(
        -o StrictHostKeyChecking=accept-new
        -p "$port"
      )

      echo "Copying identity to $user@$host:$remote_tmp..."
      scp \
        -o StrictHostKeyChecking=accept-new \
        -P "$port" \
        "$identity" \
        "$user@$host:$remote_tmp"

      echo "Installing /etc/agenix/identity..."
      # shellcheck disable=SC2029
      ssh "''${ssh_options[@]}" "$user@$host" \
        "set -e; trap 'rm -f $remote_tmp' EXIT; \
        sudo install -D -o root -g root -m 600 \
          $remote_tmp /etc/agenix/identity"

      installed_fingerprint="$(
        ssh "''${ssh_options[@]}" "$user@$host" \
          "sudo ssh-keygen -lf /etc/agenix/identity" |
          awk '{ print $2 }'
      )"

      if [[ "$installed_fingerprint" != "$expected_fingerprint" ]]; then
        echo "Installed identity has the wrong fingerprint" >&2
        exit 1
      fi

      permissions="$(
        ssh "''${ssh_options[@]}" "$user@$host" \
          "sudo stat -c '%U:%G %a' /etc/agenix/identity"
      )"

      if [[ "$permissions" != "root:root 600" ]]; then
        echo "Installed identity has unexpected permissions: $permissions" >&2
        exit 1
      fi

      echo "Installed $planet identity: $installed_fingerprint ($permissions)"
    '';
}
