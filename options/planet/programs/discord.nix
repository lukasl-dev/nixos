{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet) wm;
  inherit (wm) hyprland;

  inherit (config.planet.programs) discord;
  inherit (config.planet.services) mullvad;
in
{
  options.planet.programs.discord = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable discord";
      example = "true";
    };

    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default =
        if hyprland.enable then
          (pkgs.unstable.vesktop.override { }).overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.unstable.makeWrapper ];
            postFixup = (old.postFixup or "") + ''
              wrapProgram $out/bin/vesktop \
                --add-flags "--enable-features=WaylandLinuxDrmSyncobj" \
                --add-flags "--disable-gpu-memory-buffer-video-frames" \
                --add-flags "--ignore-gpu-blocklist" \
                --add-flags "--enable-gpu-rasterization" \
                --add-flags "--enable-zero-copy" \
                --add-flags "--disable-gpu-sandbox"
            '';
          })
        else
          pkgs.unstable.vesktop;
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
    universe.hm = [
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
          package = discord.package;

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
