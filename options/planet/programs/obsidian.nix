{
  jail,
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet) display;
  inherit (config.planet.display) hyprland;

  inherit (config.planet.programs) obsidian;

  wrapped =
    if hyprland.enable then
      pkgs.unstable.obsidian.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.unstable.makeWrapper ];
        postFixup = (old.postFixup or "") + ''
          wrapProgram $out/bin/obsidian \
            --add-flags "--enable-features=WaylandLinuxDrmSyncobj" \
            --add-flags "--disable-gpu-memory-buffer-video-frames" \
            --add-flags "--ignore-gpu-blocklist" \
            --add-flags "--enable-gpu-rasterization" \
            --add-flags "--enable-zero-copy" \
            --add-flags "--disable-gpu-sandbox"
        '';
      })
    else
      pkgs.unstable.obsidian;

  jailed = jail "obsidian" wrapped (
    with jail.combinators;
    [
      network
      gui
      gpu
      # Electron uses profile singleton sockets below /tmp to hand CLI/protocol
      # invocations to an already-running app.  A private /tmp per jail breaks
      # `obsidian obsidian://...` / desktop URI handoff.
      (add-runtime "mkdir -p ~/.local/share/jail.nix/tmp/obsidian")
      (rw-bind (noescape "~/.local/share/jail.nix/tmp/obsidian") "/tmp")
      (persist-home "obsidian")
      (rw-bind (noescape "~/notes") (noescape "~/notes"))
      (try-rw-bind (noescape "~/.gitconfig") (noescape "~/.gitconfig"))
      (try-rw-bind (noescape "~/.config/git") (noescape "~/.config/git"))
      # Obsidian Git shells out to git/ssh. Keep the user's real ssh config and
      # keys available for fetch/push/signing, and forward ssh-agent when one is
      # active so passphrase-protected keys do not prompt from inside the jail.
      (try-rw-bind (noescape "~/.ssh") (noescape "~/.ssh"))
      (try-fwd-env "SSH_AUTH_SOCK")
      (add-runtime ''
        if [ -n "''${SSH_AUTH_SOCK-}" ] && [ -S "$SSH_AUTH_SOCK" ]; then
          RUNTIME_ARGS+=(--bind "$SSH_AUTH_SOCK" "$SSH_AUTH_SOCK")
        fi
      '')
      # pi writes pasted clipboard images to /tmp/pi-clipboard-*.  Obsidian's
      # private jail /tmp otherwise hides them, so pasting images fails with
      # "permission denied"/missing file.
      (add-runtime ''
        for file in /tmp/pi-clipboard-*; do
          [ -e "$file" ] || continue
          RUNTIME_ARGS+=(--ro-bind "$file" "$file")
        done
      '')
      open-urls-in-browser
      (readwrite "/run/dbus")
      (add-pkg-deps [
        pkgs.xdg-utils
        pkgs.git
        pkgs.git-lfs
        pkgs.openssh
      ])
      (add-runtime ''
        for dev in /dev/nvidia*; do
          [ -e "$dev" ] || continue
          RUNTIME_ARGS+=(--dev-bind "$dev" "$dev")
        done
      '')
      (dbus {
        talk = [
          "org.freedesktop.portal.*"
          "org.freedesktop.Notifications"
        ];
      })
    ]
  );
in
{
  options.planet.programs = {
    obsidian = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = display.enable;
        description = "Enable obsidian";
      };

      package = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        default = pkgs.symlinkJoin {
          name = "obsidian";
          paths = [
            jailed
            wrapped
          ];
        };
        description = "Package used for Obsidian.";
        example = "pkgs.unstable.obsidian";
      };
    };
  };

  config = lib.mkIf obsidian.enable {
    environment.systemPackages = [ obsidian.package ];

    planet = {
      display.hyprland.lua =
        let
          exe = lib.getExe obsidian.package;
        in
        [
          # lua
          ''
            hl.bind("SUPER + P", hl.dsp.exec_cmd("${exe}"))
          ''
        ];

      hm = [
        {
          xdg.mimeApps.defaultApplications = {
            "x-scheme-handler/obsidian" = "obsidian.desktop";
          };
        }
      ];
    };
  };
}
