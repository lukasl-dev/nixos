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
  inherit (config.planet.networking) mullvad;

  inherit (config.planet.programs) discord;

  ozoneFlag = "--ozone-platform=${toString display.type}";
  vesktopFeatures = builtins.concatStringsSep "," (
    lib.optionals (hyprland.enable && display.type == "wayland") [ "WaylandLinuxDrmSyncobj" ]
  );

  wrapped =
    if hyprland.enable then
      (pkgs.unstable.vesktop.override { }).overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.unstable.makeWrapper ];
        postFixup = (old.postFixup or "") + ''
          wrapProgram $out/bin/vesktop \
            --add-flags "${ozoneFlag}" ${
              lib.optionalString (
                vesktopFeatures != ""
              ) "\\\n                --add-flags \"--enable-features=${vesktopFeatures}\""
            }
        '';
      })
    else
      pkgs.unstable.vesktop;

  jailed = jail "vesktop" wrapped (
    with jail.combinators;
    [
      network
      gui # includes Wayland, Pulse, and PipeWire sockets
      gpu
      # xdg-desktop-portal identifies callers by pid.  Keeping Vesktop in the
      # host pid namespace avoids portal/pidns confusion during screen sharing.
      (share-ns "pid")
      (tmpfs "/dev/shm")
      # Chromium/Electron profile singleton sockets live below /tmp.  A stable
      # per-app /tmp keeps follow-up launches from opening broken profiles.
      (add-runtime "mkdir -p ~/.local/share/jail.nix/tmp/vesktop")
      (rw-bind (noescape "~/.local/share/jail.nix/tmp/vesktop") "/tmp")
      (persist-home "vesktop")
      camera
      notifications
      open-urls-in-browser
      # Needed by xdg-document-portal/file chooser and harmless for screencast.
      (unsafe-add-raw-args ''--bind-try "$XDG_RUNTIME_DIR/doc" "$XDG_RUNTIME_DIR/doc"'')
      # Let libdbus/system helpers see the session/system bus paths while the
      # actual session bus traffic remains filtered by xdg-dbus-proxy below.
      (readwrite "/run/dbus")
      (add-pkg-deps [ pkgs.xdg-utils ])
      (add-runtime ''
        for dev in /dev/nvidia*; do
          [ -e "$dev" ] || continue
          RUNTIME_ARGS+=(--dev-bind "$dev" "$dev")
        done
      '')
      (wrap-entry (_: ''
        exec ${lib.getExe wrapped} \
          --no-sandbox \
          --disable-gpu-sandbox \
          "$@"
      ''))
      (dbus {
        talk = [
          "org.freedesktop.portal.*"
          "org.freedesktop.Notifications"
          "org.freedesktop.secrets"
          "org.mpris.*"
          "org.kde.StatusNotifierItem.*"
        ];
      })
    ]
  );
in
{
  options.planet.programs.discord = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = display.enable;
      description = "Enable discord";
      example = "true";
    };

    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = wrapped;
      # default = pkgs.symlinkJoin {
      #   name = "vesktop";
      #   paths = [
      #     jailed
      #     wrapped
      #   ];
      # };
      description = "Package used for Vesktop.";
      example = "pkgs.unstable.vesktop";
    };

    launch = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default =
        if mullvad.enable then
          "mullvad-exclude ${lib.getExe discord.package}"
        else
          lib.getExe discord.package;
      description = "Command used to launch Vesktop.";
      example = "mullvad-exclude vesktop";
    };
  };

  config = lib.mkIf discord.enable {
    planet.display.hyprland.autoStart = lib.mkIf hyprland.enable [ discord.launch ];

    planet.hm = [
      {
        xdg.desktopEntries = lib.mkIf mullvad.enable {
          vesktop = {
            name = "Vesktop";
            exec = "${discord.launch} %U";
            icon = "vesktop";
            comment = "Vesktop (Mullvad-excluded)";
            categories = [
              "Network"
              "InstantMessaging"
              "Chat"
            ];
            terminal = false;
            mimeType = [ "x-scheme-handler/discord" ];
          };
        };

        programs.vesktop = {
          enable = true;

          inherit (discord) package;

          vencord.settings = {
            autoUpdate = true;
            autoUpdateNotification = true;
            useQuickCss = true;
            themeLinks = [
              "https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css"
            ];
            enabledThemes = [ ];
            enableReactDevtools = false;
            frameless = false;
            transparent = false;
            winCtrlQ = false;
            disableMinSize = false;
            winNativeTitleBar = false;
            plugins = {
              ChatInputButtonAPI.enabled = true;
              CommandsAPI.enabled = true;
              MessageAccessoriesAPI.enabled = true;
              MessageEventsAPI.enabled = true;
              CrashHandler.enabled = true;
              FakeNitro = {
                enabled = true;
                enableEmojiBypass = true;
                emojiSize = 48;
                transformEmojis = true;
                enableStickerBypass = true;
                stickerSize = 160;
                transformStickers = true;
                transformCompoundSentence = false;
                enableStreamQualityBypass = false;
                useHyperLinks = true;
                hyperLinkText = "{{NAME}}";
                disableEmbedPermissionCheck = false;
              };
              NoDevtoolsWarning.enabled = true;
              SilentTyping = {
                enabled = true;
                isEnabled = true;
                showIcon = false;
              };
              TypingIndicator = {
                enabled = true;
                includeMutedChannels = false;
                includeCurrentChannel = true;
              };
              TypingTweaks = {
                enabled = true;
                alternativeFormatting = true;
              };
              WebKeybinds.enabled = true;
              WebScreenShareFixes.enabled = true;
              NoTrack = {
                enabled = true;
                disableAnalytics = true;
              };
              WebContextMenus = {
                enabled = true;
                addBack = true;
              };
              Settings = {
                enabled = true;
                settingsLocation = "aboveNitro";
              };
              SupportHelper.enabled = true;
              BadgeAPI.enabled = true;
            };
            notifications = {
              timeout = 5000;
              position = "bottom-right";
              useNative = "not-focused";
              logLimit = 50;
            };
            cloud = {
              authenticated = false;
              url = "https://api.vencord.dev/";
              settingsSync = false;
              settingsSyncVersion = 1739212854099;
            };
          };

          settings = {
            checkUpdates = true;
            arRPC = false;
            hardwareAcceleration = true;
            discordBranch = "stable";
          };
        };
      }
    ];
  };
}
