let
  mainMod = "SUPER";
in
{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = mainMod;

    bind = [
      "${mainMod}, Space, exec, rofi -show drun -show-icons"
      "${mainMod}, S, exec, hyprshot -m region --clipboard-only"
      "${mainMod}, P, exec, vesktop"
      "${mainMod}, T, exec, alacritty"
      "${mainMod}, B, exec, brave"
      "${mainMod}, Q, killactive,"
      # "${mainMod}, M, exit,"
      "${mainMod}, E, exec, dolphin"
      "${mainMod}, V, togglefloating,"
      "${mainMod}, R, exec, wofi --show drun"
      # "${mainMod}, P, pseudo, # dwindle"
      # "${mainMod}, J, togglesplit, # dwindle"
      "${mainMod}, h, movefocus, l"
      "${mainMod}, l, movefocus, r"
      "${mainMod}, k, movefocus, u"
      "${mainMod}, j, movefocus, d"
      "${mainMod}, 1, workspace, 1"
      "${mainMod}, 2, workspace, 2"
      "${mainMod}, 3, workspace, 3"
      "${mainMod}, 4, workspace, 4"
      "${mainMod}, 5, workspace, 5"
      "${mainMod}, 6, workspace, 6"
      "${mainMod}, 7, workspace, 7"
      "${mainMod}, 8, workspace, 8"
      "${mainMod}, 9, workspace, 9"
      "${mainMod}, 0, workspace, 10"
      "${mainMod}, M, fullscreen,"
      "${mainMod} SHIFT, 1, movetoworkspace, 1"
      "${mainMod} SHIFT, 2, movetoworkspace, 2"
      "${mainMod} SHIFT, 3, movetoworkspace, 3"
      "${mainMod} SHIFT, 4, movetoworkspace, 4"
      "${mainMod} SHIFT, 5, movetoworkspace, 5"
      "${mainMod} SHIFT, 6, movetoworkspace, 6"
      "${mainMod} SHIFT, 7, movetoworkspace, 7"
      "${mainMod} SHIFT, 8, movetoworkspace, 8"
      "${mainMod} SHIFT, 9, movetoworkspace, 9"
      "${mainMod} SHIFT, 0, movetoworkspace, 10"
      # "${mainMod}, S, togglespecialworkspace, magic"
      # "${mainMod} SHIFT, S, movetoworkspace, special:magic"
      "${mainMod}, mouse_down, workspace, e+1"
      "${mainMod}, mouse_up, workspace, e-1"
    ];

    bindm = [
      "${mainMod}, mouse:272, movewindow"
      "${mainMod}, mouse:273, resizewindow"
    ];
  };
}