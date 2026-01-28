{
  inputs,
  config,
  lib,
  ...
}:

lib.mkIf config.planet.wm.enable {
  universe.hm = [
    {
      imports = [ inputs.noctalia.homeModules.default ];

      programs.noctalia-shell = {
        enable = true;
        systemd.enable = true;

        settings = {
          settingsVersion = 43;

          general.avatarImage = "${../../../avatar.png}";

          ui = {
            fontDefault = "Adwaita Sans";
            fontFixed = "monospace";
          };

          location = {
            name = "Vienna";
            hideWeatherTimezone = true;
            hideWeatherCityName = true;
          };

          bar.widgets = {
            left = [
              {
                id = "Clock";
                formatHorizontal = "HH:mm ddd, MMM dd";
                formatVertical = "HH mm - dd MM";
                tooltipFormat = "HH:mm ddd, MMM dd";
              }
              {
                id = "SystemMonitor";
                compactMode = true;
                showCpuTemp = true;
                showCpuUsage = true;
                showMemoryUsage = true;
              }
              { id = "plugin:catwalk"; }
              { id = "plugin:network-indicator"; }
              {
                id = "VPN";
                displayMode = "onhover";
              }
              {
                id = "plugin:tailscale";
              }
            ];
            center = [
              {
                id = "Workspace";
                characterCount = 2;
                showApplications = true;
                showLabelsOnlyWhenOccupied = true;
                colorizeIcons = true;
              }
            ];
            right = [
              {
                id = "MediaMini";
                maxWidth = 145;
                visualizerType = "wave";
                compactShowAlbumArt = true;
                panelShowAlbumArt = true;
                panelShowVisualizer = true;
                showAlbumArt = true;
                showArtistFirst = true;
                showProgressRing = true;
                showVisualizer = true;
              }
              { id = "plugin:privacy-indicator"; }
              {
                id = "Tray";
                drawerEnabled = true;
              }
              {
                id = "NotificationHistory";
                showUnreadBadge = true;
              }
              {
                id = "Battery";
                hideIfNotDetected = true;
                warningThreshold = 30;
              }
              {
                id = "Volume";
                middleClickCommand = "pwvucontrol || pavucontrol";
              }
              { id = "Brightness"; }
              {
                id = "ControlCenter";
                icon = "noctalia";
              }
            ];
          };

          wallpaper = {
            overviewEnabled = true;
            directory = "${lib.cleanSourceWith {
              src = ../../../wallpapers;
              filter = path: type: builtins.baseNameOf path != "README.md";
            }}";
            automationEnabled = true;
          };

          appLauncher = {
            enableClipboardHistory = true;
          };

          dock = {
            enabled = false;
          };

          nightLight = {
            enabled = true;
          };
        };

        plugins = {
          sources = [
            {
              enabled = true;
              name = "Official Noctalia Plugins";
              url = "https://github.com/noctalia-dev/noctalia-plugins";
            }
          ];
          states = {
            catwalk = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
            network-indicator = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
            privacy-indicator = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
            tailscale = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
          };
          version = 1;
        };

        pluginSettings = {
          catwalk = {
            minimumThreshold = 25;
            hideBackground = true;
          };
          tailscale = {
            compactMode = true;
          };
        };

        colors = {
          mPrimary = "#cba6f7";
          mOnPrimary = "#1e1e2e";
          mSecondary = "#f5c2e7";
          mOnSecondary = "#1e1e2e";
          mTertiary = "#89dceb";
          mOnTertiary = "#1e1e2e";
          mError = "#f38ba8";
          mOnError = "#1e1e2e";
          mSurface = "#1e1e2e";
          mOnSurface = "#cdd6f4";
          mSurfaceVariant = "#181825";
          mOnSurfaceVariant = "#bac2de";
          mOutline = "#6c7086";
          mShadow = "#11111b";
          mHover = "#313244";
          mOnHover = "#cdd6f4";
        };
      };
    }
  ];
}
