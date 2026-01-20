{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  inherit (config.planet) wm;
  inherit (wm) hyprland;

  inherit (config.planet.programs) discord;
in
{
  options.planet.programs.discord = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable discord";
      example = "true";
    };
  };

  config = lib.mkIf discord.enable {
    universe.hm = [
      {
        programs.vesktop = {
          enable = true;
          package =
            if hyprland.enable then
              (pkgs-unstable.vesktop.override { }).overrideAttrs (old: {
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs-unstable.makeWrapper ];
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
              pkgs-unstable.vesktop;

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
