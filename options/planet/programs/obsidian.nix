{
  jail,
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet) display ssh;
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
      # Home Manager makes ~/.config/git/config and ~/.ssh/config symlinks into
      # /nix/store. Materialize regular files in the persisted jail home: this
      # keeps using the generated config without duplicating it here, avoids
      # extra store-target binds, and satisfies OpenSSH's strict permission
      # checks for ~/.ssh/config.
      (add-runtime ''
        install -d -m 700 ~/.local/share/jail.nix/home/obsidian/.config/git
        install -d -m 700 ~/.local/share/jail.nix/home/obsidian/.ssh

        if [ -e ~/.config/git/config ]; then
          install -m 600 "$(realpath ~/.config/git/config)" ~/.local/share/jail.nix/home/obsidian/.config/git/config
        fi

        if [ -e ~/.config/git/ignore ]; then
          install -m 600 ~/.config/git/ignore ~/.local/share/jail.nix/home/obsidian/.config/git/ignore
        fi

        if [ -e ~/.ssh/config ]; then
          install -m 600 "$(realpath ~/.ssh/config)" ~/.local/share/jail.nix/home/obsidian/.ssh/config
        fi

        for file in known_hosts known_hosts2; do
          if [ -e ~/.ssh/$file ]; then
            install -m 600 ~/.ssh/$file ~/.local/share/jail.nix/home/obsidian/.ssh/$file
          fi
        done
      '')
      (try-ro-bind (toString ssh.default.privateKey) (toString ssh.default.privateKey))
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
          exe = lib.getExe' obsidian.package "obsidian";
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
