{ pkgs }:

pkgs.writeShellApplication {
  name = "planet_update_helium";
  runtimeInputs = with pkgs; [
    gh
    jq
    coreutils
    gnugrep
    gnused
    xxd
  ];
  text = # bash
    ''
      set -euo pipefail

      file="options/planet/programs/helium.nix"

      release_json="$(gh api repos/imputnet/helium-linux/releases/latest)"
      tag="$(jq -r '.tag_name' <<< "''${release_json}")"

      x86_digest="$(jq -r --arg tag "''${tag}" '.assets[] | select(.name == ("helium-" + $tag + "-x86_64_linux.tar.xz")) | .digest' <<< "''${release_json}")"
      arm_digest="$(jq -r --arg tag "''${tag}" '.assets[] | select(.name == ("helium-" + $tag + "-arm64_linux.tar.xz")) | .digest' <<< "''${release_json}")"

      if [[ -z "''${x86_digest}" || "''${x86_digest}" == "null" || -z "''${arm_digest}" || "''${arm_digest}" == "null" ]]; then
        echo "Could not find release digests for helium ''${tag}" >&2
        exit 1
      fi

      x86_hex="''${x86_digest#sha256:}"
      arm_hex="''${arm_digest#sha256:}"

      if ! grep -Eq '^[0-9a-f]{64}$' <<< "''${x86_hex}"; then
        echo "Unexpected x86 digest format: ''${x86_digest}" >&2
        exit 1
      fi

      if ! grep -Eq '^[0-9a-f]{64}$' <<< "''${arm_hex}"; then
        echo "Unexpected arm64 digest format: ''${arm_digest}" >&2
        exit 1
      fi

      x86_hash="sha256-$(printf '%s' "''${x86_hex}" | xxd -r -p | base64 -w0)"
      arm_hash="sha256-$(printf '%s' "''${arm_hex}" | xxd -r -p | base64 -w0)"

      before="$(sha256sum "''${file}")"

      sed -Ei "s#(heliumVersion = \")[^\"]+(\";)#\1''${tag}\2#" "''${file}"
      sed -Ei "/x86_64-linux = \\{/,/\\};/ s#(hash = \")[^\"]+(\";)#\\1''${x86_hash}\\2#" "''${file}"
      sed -Ei "/aarch64-linux = \\{/,/\\};/ s#(hash = \")[^\"]+(\";)#\\1''${arm_hash}\\2#" "''${file}"

      after="$(sha256sum "''${file}")"
      if [[ "''${before}" == "''${after}" ]]; then
        echo "No changes were applied to ''${file}" >&2
        exit 1
      fi

      echo "Updated helium.nix to ''${tag}"
    '';
}
