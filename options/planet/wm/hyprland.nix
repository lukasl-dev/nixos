{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
  hypr-nixpkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};

  monitorToString =
    monitor:
    builtins.concatStringsSep ", " [
      monitor.output
      monitor.mode
      monitor.position
      (builtins.toString monitor.scale)
    ];
in
{
  imports = [ inputs.hyprland.nixosModules.default ];

  options.planet.wm.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland";

    lua = lib.mkOption {
      type = lib.types.listOf lib.types.lines;
      default = [ ];
      example = [
        # lua
        ''
          local x = "hello"
          print(x)
        ''
      ];
      description = "Lua snippets to include in the generated Hyprland Lua config.";
    };

    monitors = lib.mkOption {
      type =
        with lib.types;
        listOf (submodule {
          options = {
            output = lib.mkOption {
              type = str;
              description = "Monitor output name.";
              example = "DP-1";
            };
            mode = lib.mkOption {
              type = str;
              description = "Monitor mode and refresh rate.";
              example = "1920x1080@144";
            };
            position = lib.mkOption {
              type = str;
              description = "Monitor position.";
              example = "0x0";
            };
            scale = lib.mkOption {
              type = number;
              description = "Monitor scale factor.";
              example = 1;
            };
          };
        });
      default = [ ];
      example = [
        {
          output = "DP-1";
          mode = "1920x1080@144";
          position = "0x0";
          scale = 1;
        }
      ];
      description = "List of Hyprland monitors.";
    };

    bind = lib.mkOption {
      type =
        with lib.types;
        listOf (submodule {
          options = {
            keys = lib.mkOption {
              type = listOf str;
              description = "Key chord parts for the bind.";
              example = [
                "SUPER"
                "SHIFT"
                "Q"
              ];
            };

            dispatcher = lib.mkOption {
              type = submodule {
                options = {
                  exec_cmd = lib.mkOption {
                    type = nullOr str;
                    default = null;
                    description = "Exec command payload.";
                    example = "firefox";
                  };

                  lua = lib.mkOption {
                    type = nullOr lines;
                    default = null;
                    description = "Lua expression or function payload.";
                    example = ''
                      function()
                        -- some logic...
                        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
                      end
                    '';
                  };

                  window = lib.mkOption {
                    type = nullOr (submodule {
                      options = {
                        center = lib.mkOption {
                          type = nullOr attrs;
                          default = null;
                          description = "Window.center payload.";
                          example = { };
                        };

                        float = lib.mkOption {
                          type = nullOr attrs;
                          default = null;
                          description = "Window.float payload.";
                          example = {
                            action = "toggle";
                          };
                        };
                      };
                    });
                    default = null;
                    description = "Window dispatcher payload.";
                  };
                };
              };
              default = { };
              apply =
                d:
                let
                  hasExec = d.exec_cmd != null;
                  hasLua = d.lua != null;
                  hasWindow = d.window != null;
                in
                if
                  builtins.length (
                    builtins.filter lib.id [
                      hasExec
                      hasLua
                      hasWindow
                    ]
                  ) != 1
                then
                  throw "Hyprland bind.dispatcher must have exactly one of 'exec_cmd', 'lua', or 'window'"
                else if hasWindow then
                  let
                    w = d.window;
                    hasCenter = w.center != null;
                    hasFloat = w.float != null;
                  in
                  if hasCenter == hasFloat then
                    throw "Hyprland bind.dispatcher.window must have exactly one of 'center' or 'float'"
                  else
                    d
                else
                  d;
              description = "Dispatcher payload for hl.bind.";
              example = {
                exec_cmd = "firefox";
              };
            };
          };
        });
      default = [ ];
      example = [
        {
          keys = [
            "SUPER"
            "SHIFT"
            "Q"
          ];
          dispatcher = {
            exec_cmd = "firefox";
          };
        }
        {
          keys = [
            "SUPER"
            "SHIFT"
            "X"
          ];
          dispatcher = {
            lua = ''
              function()
                -- some logic...
                hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
              end
            '';
          };
        }
        {
          keys = [
            "SUPER"
            "SHIFT"
            "C"
          ];
          dispatcher = {
            window = {
              center = { };
            };
          };
        }
        {
          keys = [
            "SUPER"
            "SHIFT"
            "F"
          ];
          dispatcher = {
            window = {
              float = {
                action = "toggle";
              };
            };
          };
        }
      ];
      description = "Lua bind declarations for later rendering.";
    };

    launch = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Commands started via Hyprland exec-once.";
      example = [ "vesktop" ];
    };

    bindings = lib.mkOption {
      type =
        with lib.types;
        listOf (submodule {
          options = {
            type = lib.mkOption {
              type = enum [
                "exec"
                "dispatch"
              ];
              description = "Binding variant.";
            };

            mods = lib.mkOption {
              type = listOf str;
              default = [ "SUPER" ];
              description = "Modifier combinations, each entry producing bindings for all keys.";
              example = [
                "SUPER"
                "ALT"
              ];
            };

            keys = lib.mkOption {
              type = listOf str;
              default = [ ];
              description = "Key names for the binding.";
              example = [
                "Space"
                "Backspace"
              ];
            };

            command = lib.mkOption {
              type = nullOr str;
              default = null;
              description = "Command to execute for exec bindings.";
              example = "ghostty";
            };

            dispatcher = lib.mkOption {
              type = nullOr str;
              default = null;
              description = "Hyprland dispatcher for dispatch bindings.";
              example = "movetoworkspace";
            };

            argument = lib.mkOption {
              type = str;
              default = "";
              description = "Argument passed to the dispatcher.";
              example = "special";
            };
          };
        });
      default = [ ];
      description = "Structured Hyprland bindings.";
      example = [
        {
          type = "exec";
          mods = [ "SUPER" ];
          keys = [ "Return" ];
          command = "ghostty";
        }
        {
          type = "dispatch";
          keys = [ "Q" ];
          dispatcher = "togglespecialworkspace";
        }
      ];
    };
  };

  config = lib.mkIf config.planet.wm.hyprland.enable {
    nix.settings = {
      extra-substituters = [
        "https://hyprland.cachix.org"
      ];
      extra-trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    security.polkit.enable = true;

    # TODO: update and enable this:
    # services.hyprpolkitagent.enable = true;

    planet.wm.hyprland = {
      bind =
        let
          window = [ "SUPER" ];
          windowShift = [
            "SUPER"
            "SHIFT"
          ];
        in
        [
          # screenshotting
          {
            keys = window ++ [ "S" ];
            dispatcher.exec_cmd = ''grim -g "$(slurp -d)" - | wl-copy'';
          }
          {
            keys = windowShift ++ [ "S" ];
            dispatcher.exec_cmd = "hyprshot -m window -m active --clipboard-only";
          }

          # floating
          {
            keys = window ++ [ "V" ];
            dispatcher.window.float = { };
          }
          {
            keys = window ++ [ "V" ];
            dispatcher.window.center = { };
          }

          # moving windows
          {
            keys = windowShift ++ [ "H" ];
            dispatcher.layout = "swapcol l";
          }
          {
            keys = windowShift ++ [ "L" ];
            dispatcher.layout = "swapcol r";
          }

          # focus windows
          {
            keys = window ++ [ "H" ];
            dispatcher.layout = "focus l";
          }
          {
            keys = window ++ [ "L" ];
            dispatcher.layout = "focus r";
          }
          {
            keys = window ++ [ "K" ];
            dispatcher.movefocus = {
              direction = "u";
            };
          }
          {
            keys = window ++ [ "J" ];
            dispatcher.movefocus = {
              direction = "d";
            };
          }

          # kill window
          {
            keys = window ++ [ "W" ];
            dispatcher.kill = { };
          }

          # fullscreen
          {
            keys = window ++ [ "M" ];
            dispatcher.fullscreen = {
              mode = "maximized";
            };
          }
          {
            keys = windowShift ++ [ "M" ];
            dispatcher.fullscreen = {
              mode = "fullscreen";
            };
          }

          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "1" ];
          #   dispatcher = "workspace";
          #   argument = "1";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "2" ];
          #   dispatcher = "workspace";
          #   argument = "2";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "3" ];
          #   dispatcher = "workspace";
          #   argument = "3";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "4" ];
          #   dispatcher = "workspace";
          #   argument = "4";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "5" ];
          #   dispatcher = "workspace";
          #   argument = "5";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "6" ];
          #   dispatcher = "workspace";
          #   argument = "6";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "7" ];
          #   dispatcher = "workspace";
          #   argument = "7";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "8" ];
          #   dispatcher = "workspace";
          #   argument = "8";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "9" ];
          #   dispatcher = "workspace";
          #   argument = "9";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "0" ];
          #   dispatcher = "workspace";
          #   argument = "10";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowShiftMods;
          #   keys = [ "1" ];
          #   dispatcher = "movetoworkspace";
          #   argument = "1";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowShiftMods;
          #   keys = [ "2" ];
          #   dispatcher = "movetoworkspace";
          #   argument = "2";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowShiftMods;
          #   keys = [ "3" ];
          #   dispatcher = "movetoworkspace";
          #   argument = "3";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowShiftMods;
          #   keys = [ "4" ];
          #   dispatcher = "movetoworkspace";
          #   argument = "4";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowShiftMods;
          #   keys = [ "5" ];
          #   dispatcher = "movetoworkspace";
          #   argument = "5";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowShiftMods;
          #   keys = [ "6" ];
          #   dispatcher = "movetoworkspace";
          #   argument = "6";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowShiftMods;
          #   keys = [ "7" ];
          #   dispatcher = "movetoworkspace";
          #   argument = "7";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowShiftMods;
          #   keys = [ "8" ];
          #   dispatcher = "movetoworkspace";
          #   argument = "8";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowShiftMods;
          #   keys = [ "9" ];
          #   dispatcher = "movetoworkspace";
          #   argument = "9";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowShiftMods;
          #   keys = [ "0" ];
          #   dispatcher = "movetoworkspace";
          #   argument = "10";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "mouse_down" ];
          #   dispatcher = "workspace";
          #   argument = "e+1";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "mouse_up" ];
          #   dispatcher = "workspace";
          #   argument = "e-1";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "comma" ];
          #   dispatcher = "layoutmsg";
          #   argument = "move -col";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "period" ];
          #   dispatcher = "layoutmsg";
          #   argument = "move +col";
          # }
          # {
          #   type = "dispatch";
          #   mods = [ "SUPER ALT" ];
          #   keys = [ "minus" ];
          #   dispatcher = "layoutmsg";
          #   argument = "colresize -0.1";
          # }
          # {
          #   type = "dispatch";
          #   mods = [ "SUPER ALT" ];
          #   keys = [ "equal" ];
          #   dispatcher = "layoutmsg";
          #   argument = "colresize +0.1";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "minus" ];
          #   dispatcher = "layoutmsg";
          #   argument = "colresize -conf";
          # }
          # {
          #   type = "dispatch";
          #   mods = windowMods;
          #   keys = [ "equal" ];
          #   dispatcher = "layoutmsg";
          #   argument = "colresize +conf";
          # }
        ];

      bindings =
        let
          windowMods = [
            "SUPER"
            "ALT"
          ];

          windowShiftMods = [
            "SUPER SHIFT"
            "ALT SHIFT"
          ];
        in
        [
          {
            type = "exec";
            keys = [ "S" ];
            command = ''grim -g "$(slurp -d)" - | wl-copy'';
          }
          {
            type = "exec";
            mods = [ "SUPER SHIFT" ];
            keys = [ "S" ];
            command = "hyprshot -m window -m active --clipboard-only";
          }
          {
            type = "dispatch";
            keys = [ "Q" ];
            dispatcher = "togglespecialworkspace";
          }
          {
            type = "dispatch";
            mods = [ "SUPER SHIFT" ];
            keys = [ "Q" ];
            dispatcher = "movetoworkspace";
            argument = "special";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "V" ];
            dispatcher = "togglefloating";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "V" ];
            dispatcher = "centerwindow";
          }
          {
            type = "dispatch";
            mods = windowShiftMods;
            keys = [ "H" ];
            dispatcher = "layoutmsg";
            argument = "swapcol l";
          }
          {
            type = "dispatch";
            mods = windowShiftMods;
            keys = [ "L" ];
            dispatcher = "layoutmsg";
            argument = "swapcol r";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "N" ];
            dispatcher = "swapnext";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "F" ];
            dispatcher = "pseudo";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "W" ];
            dispatcher = "killactive";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "M" ];
            dispatcher = "fullscreen";
            argument = "1";
          }
          {
            type = "dispatch";
            mods = windowShiftMods;
            keys = [ "M" ];
            dispatcher = "fullscreen";
          }

          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "h" ];
            dispatcher = "layoutmsg";
            argument = "focus l";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "l" ];
            dispatcher = "layoutmsg";
            argument = "focus r";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "k" ];
            dispatcher = "movefocus";
            argument = "u";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "j" ];
            dispatcher = "movefocus";
            argument = "d";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "1" ];
            dispatcher = "workspace";
            argument = "1";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "2" ];
            dispatcher = "workspace";
            argument = "2";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "3" ];
            dispatcher = "workspace";
            argument = "3";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "4" ];
            dispatcher = "workspace";
            argument = "4";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "5" ];
            dispatcher = "workspace";
            argument = "5";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "6" ];
            dispatcher = "workspace";
            argument = "6";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "7" ];
            dispatcher = "workspace";
            argument = "7";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "8" ];
            dispatcher = "workspace";
            argument = "8";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "9" ];
            dispatcher = "workspace";
            argument = "9";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "0" ];
            dispatcher = "workspace";
            argument = "10";
          }
          {
            type = "dispatch";
            mods = windowShiftMods;
            keys = [ "1" ];
            dispatcher = "movetoworkspace";
            argument = "1";
          }
          {
            type = "dispatch";
            mods = windowShiftMods;
            keys = [ "2" ];
            dispatcher = "movetoworkspace";
            argument = "2";
          }
          {
            type = "dispatch";
            mods = windowShiftMods;
            keys = [ "3" ];
            dispatcher = "movetoworkspace";
            argument = "3";
          }
          {
            type = "dispatch";
            mods = windowShiftMods;
            keys = [ "4" ];
            dispatcher = "movetoworkspace";
            argument = "4";
          }
          {
            type = "dispatch";
            mods = windowShiftMods;
            keys = [ "5" ];
            dispatcher = "movetoworkspace";
            argument = "5";
          }
          {
            type = "dispatch";
            mods = windowShiftMods;
            keys = [ "6" ];
            dispatcher = "movetoworkspace";
            argument = "6";
          }
          {
            type = "dispatch";
            mods = windowShiftMods;
            keys = [ "7" ];
            dispatcher = "movetoworkspace";
            argument = "7";
          }
          {
            type = "dispatch";
            mods = windowShiftMods;
            keys = [ "8" ];
            dispatcher = "movetoworkspace";
            argument = "8";
          }
          {
            type = "dispatch";
            mods = windowShiftMods;
            keys = [ "9" ];
            dispatcher = "movetoworkspace";
            argument = "9";
          }
          {
            type = "dispatch";
            mods = windowShiftMods;
            keys = [ "0" ];
            dispatcher = "movetoworkspace";
            argument = "10";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "mouse_down" ];
            dispatcher = "workspace";
            argument = "e+1";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "mouse_up" ];
            dispatcher = "workspace";
            argument = "e-1";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "comma" ];
            dispatcher = "layoutmsg";
            argument = "move -col";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "period" ];
            dispatcher = "layoutmsg";
            argument = "move +col";
          }
          {
            type = "dispatch";
            mods = [ "SUPER ALT" ];
            keys = [ "minus" ];
            dispatcher = "layoutmsg";
            argument = "colresize -0.1";
          }
          {
            type = "dispatch";
            mods = [ "SUPER ALT" ];
            keys = [ "equal" ];
            dispatcher = "layoutmsg";
            argument = "colresize +0.1";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "minus" ];
            dispatcher = "layoutmsg";
            argument = "colresize -conf";
          }
          {
            type = "dispatch";
            mods = windowMods;
            keys = [ "equal" ];
            dispatcher = "layoutmsg";
            argument = "colresize +conf";
          }
        ];
    };

    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${system}.hyprland.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.git ];
        cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DNO_HYPRPM=ON" ];
      });

      xwayland.enable = true;
      withUWSM = false;

      settings = {
        monitor = builtins.map monitorToString config.planet.wm.hyprland.monitors ++ [
          "Unknown-1,disable"
        ];

        "$mauve" = "rgb(cba6f7)";
        "$lavender" = "rgb(b4befe)";

        env = [
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          "QT_QPA_PLATFORM,wayland"
          "NVD_BACKEND,direct"

          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "ELECTRON_OZONE_PLATFORM_HINT,auto"
        ];

        exec-once = builtins.concatLists [
          [
            "systemctl --user start hyprpolkitagent"

            # https://discourse.nixos.org/t/keyctl-read-alloc-permission-denied/8667/4
            "keyctl link @u @s"
          ]
          config.planet.wm.hyprland.launch
        ];

        bind = builtins.concatMap (
          binding:
          builtins.concatMap (
            mod:
            if binding.type == "exec" then
              if binding.command == null then
                throw "Hyprland exec binding is missing 'command'"
              else
                builtins.map (key: "${mod}, ${key}, exec, ${binding.command}") binding.keys
            else if binding.type == "dispatch" then
              if binding.dispatcher == null then
                throw "Hyprland dispatch binding is missing 'dispatcher'"
              else
                builtins.map (key: "${mod}, ${key}, ${binding.dispatcher}, ${binding.argument}") binding.keys
            else
              throw "Unsupported Hyprland binding type: ${binding.type}"
          ) binding.mods
        ) config.planet.wm.hyprland.bindings;

        bindm = [
          "SUPER, mouse:272, movewindow"
          "ALT, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
          "ALT, mouse:273, resizewindow"
        ];

        windowrule = [
          # ========= ========= ========= ========= ========= =========
          # 1Password
          # ========= ========= ========= ========= ========= =========

          "float on, match:class 1Password"
          "center on, match:class 1Password"
          "opacity 0.8, match:class 1Password"
          "size 1309 783, match:class 1Password"

          # ========= ========= ========= ========= ========= =========
          # Bitwarden
          # ========= ========= ========= ========= ========= =========

          # Desktop App
          "float on, match:title Bitwarden"
          "center on, match:title Bitwarden"
          "opacity 0.8, match:title Bitwarden"
          "size 1309 783, match:title Bitwarden"

          # Bitwarden Brave Popups
          "float on, match:initial_class brave-nngceckbapebfimnlniiiahkandclblb-Default"
          "center on, match:initial_class brave-nngceckbapebfimnlniiiahkandclblb-Default"
          "opacity 0.8, match:initial_class brave-nngceckbapebfimnlniiiahkandclblb-Default"
          "size 581 783, match:initial_class brave-nngceckbapebfimnlniiiahkandclblb-Default"

          # Bitwarden Vivaldi Popups
          "float on, match:initial_title Bitwarden - Vivaldi"
          "center on, match:initial_title Bitwarden - Vivaldi"
          "opacity 0.8, match:initial_title Bitwarden - Vivaldi"
          "size 581 783, match:initial_title Bitwarden - Vivaldi"

          # ========= ========= ========= ========= ========= =========
          # Brave
          # ========= ========= ========= ========= ========= =========

          "float on, match:title Sign in – Google accounts - Brave"
          "center on, match:title Sign in – Google accounts - Brave"

          # ========= ========= ========= ========= ========= =========
          # Vesktop
          # ========= ========= ========= ========= ========= =========

          "render_unfocused on, match:initial_class vesktop"
          "workspace 1, match:initial_class vesktop"
          "no_initial_focus on, match:initial_class vesktop"

          # File Download
          "float on, match:initial_title https://discord.com/.*"
          "pin on, match:initial_title https://discord.com/.*"
          "opacity 0.8, match:initial_title https://discord.com/.*"
          "center on, match:initial_title https://discord.com/.*"
          "size 934 489, match:initial_title https://discord.com/.*"

          # ========= ========= ========= ========= ========= =========
          # Element
          # ========= ========= ========= ========= ========= =========

          "render_unfocused on, match:initial_class Element"
          "workspace 1, match:initial_class Element"
          "no_initial_focus on, match:initial_class Element"

          # ========= ========= ========= ========= ========= =========
          # Minecraft
          # ========= ========= ========= ========= ========= =========

          "no_anim on, match:initial_class ^Minecraft\\*\\s1\\.20\\.6$"
          "no_blur on, match:initial_class ^Minecraft\\*\\s1\\.20\\.6$"

          # ========= ========= ========= ========= ========= =========
          # Picture-in-picture (PiP)
          # ========= ========= ========= ========= ========= =========

          "float on, match:initial_title Picture-in-picture"
          "pin on, match:initial_title Picture-in-picture"

          "float on, match:initial_title Picture-in-Picture"
          "pin on, match:initial_title Picture-in-Picture"

          "float on, match:initial_title Picture in picture"
          "pin on, match:initial_title Picture in picture"

          # ========= ========= ========= ========= ========= =========
          # YouTube Music
          # ========= ========= ========= ========= ========= =========

          "workspace 1, match:initial_class YouTube.Music"

          # ========= ========= ========= ========= ========= =========
          # XDG Desktop Portal
          # ========= ========= ========= ========= ========= =========

          "float on, match:initial_class Xdg-desktop-portal-gtk"
          "pin on, match:initial_class Xdg-desktop-portal-gtk"
          "opacity 0.8, match:initial_class Xdg-desktop-portal-gtk"
          "center on, match:initial_class Xdg-desktop-portal-gtk"
          "size 934 489, match:initial_class Xdg-desktop-portal-gtk"

          # ========= ========= ========= ========= ========= =========
          # Steam
          # ========= ========= ========= ========= ========= =========

          # Friend List
          "float on, match:initial_class steam, match:initial_title Friends List"
          "center on, match:initial_class steam, match:initial_title Friends List"
          "size 524 706, match:initial_class steam, match:initial_title Friends List"

          "render_unfocused on, match:initial_class steam_app_2622380"

          # ========= ========= ========= ========= ========= =========
          # Obsidian
          # ========= ========= ========= ========= ========= =========
          "workspace 10, match:initial_class obsidian"
          # "no_initial_focus on, match:initial_class obsidian"

          # ========= ========= ========= ========= ========= =========
          # Zen
          # ========= ========= ========= ========= ========= =========
          "float on, match:initial_class zen-beta, match:title ^Extension:.*$"
          "center on, match:initial_class zen-beta, match:title ^Extension:.*$"
          "size 524 706, match:initial_class zen-beta, match:title ^Extension:.*$"

          # ========= ========= ========= ========= ========= =========
          # Mullvad VPN
          # ========= ========= ========= ========= ========= =========
          "float on, match:initial_title Mullvad VPN"
          "pin on, match:initial_title Mullvad VPN"

          # ========= ========= ========= ========= ========= =========
          # Sioyek
          # ========= ========= ========= ========= ========= =========
          "tile on, match:class sioyek"
        ];

        cursor = {
          # 2 is 'auto', which is recommended for NVIDIA
          no_hardware_cursors = 2;
        };

        input = {
          kb_layout = "us";
          kb_variant = ",qwerty";
          follow_mouse = 1;
          touchpad = {
            natural_scroll = "yes";
          };
          sensitivity = 0;

          repeat_rate = 25;
          repeat_delay = 500;
        };

        general = {
          gaps_in = 5;
          gaps_out = 30;
          border_size = 2;

          "col.active_border" = "$mauve $lavender 45deg";
          "col.inactive_border" = "rgba(595959aa)";

          layout = "scrolling";

          allow_tearing = false;
        };

        decoration = {
          rounding = 10;
          dim_modal = true;

          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };
        };

        animations = {
          enabled = "yes";
        };

        bezier = [
          "myBezier, 0.05, 0.9, 0.1, 1.05"
        ];

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];

        scrolling = {
          fullscreen_on_one_column = true;
          column_width = 0.5;
          focus_fit_method = 1;
          follow_focus = true;
          follow_min_visible = 0.4;
          explicit_column_widths = "0.333, 0.5, 0.667, 1.0";
          direction = "right";
        };

        gestures = {
        };

        misc = {
          force_default_wallpaper = 0;
          mouse_move_enables_dpms = false;
          vrr = 2;
          enable_anr_dialog = false;
          disable_hyprland_guiutils_check = true;
        };

        render = {
          direct_scanout = 0;
        };
      };
    };

    # Add GTK portal for OpenURI, file chooser, etc.

    # Don't set xdg.portal.config - let configPackages from Hyprland handle it
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    programs.dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          gtk-theme = "Adwaita";
          icon-theme = "Flat-Remix-Red-Dark";
          font-name = "Noto Sans Medium 11";
          document-font-name = "Noto Sans Medium 11";
          monospace-font-name = "Noto Sans Mono Medium 11";
        };
      }
    ];

    environment = {
      sessionVariables = {
        # hint electron apps to use ozone wayland platform
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";

        # prefer wayland over X11 for GTK apps
        GDK_BACKEND = "wayland,x11";

        # prefer wayland over xcb for QT apps
        QT_QPA_PLATFORM = "wayland;xcb";

        # fix reparenting issues with Java apps
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };

      systemPackages = [
        pkgs.unstable.hyprpicker
        pkgs.hyprquickframe

        pkgs.unstable.egl-wayland
        pkgs.wl-clipboard

        # pkgs.unstable.hyprcursor
        # pkgs.catppuccin-cursors.mochaMauve

        pkgs.grim
        pkgs.slurp
        pkgs.hyprshot

        pkgs.libnotify

        (pkgs.writeShellApplication {
          name = "waybar-toggle";
          runtimeInputs = [
            pkgs.waybar
            pkgs.procps
          ];
          text = ''
            PID_FILE="/tmp/waybar.pid"
            if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" > /dev/null; then
                kill "$(cat "$PID_FILE")"
                rm "$PID_FILE"
            else
                waybar &> /dev/null & echo $! > "$PID_FILE"
            fi
          '';
        })
      ];
    };

    hardware.graphics = {
      enable = true;
      package = hypr-nixpkgs.mesa;

      enable32Bit = true;
      package32 = hypr-nixpkgs.pkgsi686Linux.mesa;

      extraPackages = [ ];
    };

    universe.hm = [
      {
        home.pointerCursor = {
          gtk.enable = true;
          package = pkgs.catppuccin-cursors.mochaLight;
          name = "Catppuccin-Mocha-Light-Cursors";
          size = 26;
        };

        # TODO: make this configurable
        # dimming
        # services.wlsunset = {
        #   enable = true;
        #
        #   latitude = 48.2081;
        #   longitude = 16.3713;
        #
        #   temperature = {
        #     day = 6500;
        #     night = 4500;
        #   };
        # };
      }
    ];
  };
}
