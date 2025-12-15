{
  config,
  lib,
  pkgs,
  ...
}:

let
  wm = config.planet.wm;
  hyprland = wm.hyprland;
  user = config.universe.user;
in
{
  options.planet.programs.espanso = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable espanso";
    };
  };

  config = lib.mkIf config.planet.programs.espanso.enable {
    hardware.uinput.enable = true;

    users.users.${user.name}.extraGroups = lib.mkAfter [
      "uinput"
      "input"
    ];

    universe.hm = [
      {
        services.espanso = {
          enable = true;
          waylandSupport = hyprland.enable;
          x11Support = !hyprland.enable;

          configs = {
            default = {
              keyboard_layout = {
                layout = "us";
              };
              inject_delay = 0;
              key_delay = 0;
              backend = "clipboard";
            };
            ghostty = {
              filter_class = "com\\.mitchellh\\.ghostty";
              backend = "clipboard";
              paste_shortcut = "CTRL+SHIFT+V";
              pre_paste_delay = 500;
              paste_shortcut_event_delay = 100;
              restore_clipboard_delay = 500;
            };
          };

          matches = {
            writing = {
              matches = [
                {
                  trigger = ";emdash;";
                  replace = "—";
                }
                {
                  trigger = ";ae;";
                  replace = "ä";
                }
                {
                  trigger = ";Ae;";
                  replace = "Ä";
                }
                {
                  trigger = ";oe;";
                  replace = "ö";
                }
                {
                  trigger = ";Oe;";
                  replace = "Ö";
                }
                {
                  trigger = ";ue;";
                  replace = "ü";
                }
                {
                  trigger = ";Ue;";
                  replace = "Ü";
                }
                {
                  trigger = ";ss;";
                  replace = "ß";
                }
              ];
            };
            greek = {
              matches = [
                {
                  trigger = ";alpha;";
                  replace = "α";
                }
                {
                  trigger = ";Alpha;";
                  replace = "Α";
                }
                {
                  trigger = ";beta;";
                  replace = "β";
                }
                {
                  trigger = ";Beta;";
                  replace = "Β";
                }
                {
                  trigger = ";gamma;";
                  replace = "γ";
                }
                {
                  trigger = ";Gamma;";
                  replace = "Γ";
                }
                {
                  trigger = ";delta;";
                  replace = "δ";
                }
                {
                  trigger = ";Delta;";
                  replace = "Δ";
                }
                {
                  trigger = ";epsilon;";
                  replace = "ε";
                }
                {
                  trigger = ";Epsilon;";
                  replace = "Ε";
                }
                {
                  trigger = ";zeta;";
                  replace = "ζ";
                }
                {
                  trigger = ";Zeta;";
                  replace = "Ζ";
                }
                {
                  trigger = ";eta;";
                  replace = "η";
                }
                {
                  trigger = ";Eta;";
                  replace = "Η";
                }
                {
                  trigger = ";theta;";
                  replace = "θ";
                }
                {
                  trigger = ";Theta;";
                  replace = "Θ";
                }
                {
                  trigger = ";iota;";
                  replace = "ι";
                }
                {
                  trigger = ";Iota;";
                  replace = "Ι";
                }
                {
                  trigger = ";kappa;";
                  replace = "κ";
                }
                {
                  trigger = ";Kappa;";
                  replace = "Κ";
                }
                {
                  trigger = ";lambda;";
                  replace = "λ";
                }
                {
                  trigger = ";Lambda;";
                  replace = "Λ";
                }
                {
                  trigger = ";mu;";
                  replace = "μ";
                }
                {
                  trigger = ";Mu;";
                  replace = "Μ";
                }
                {
                  trigger = ";nu;";
                  replace = "ν";
                }
                {
                  trigger = ";Nu;";
                  replace = "Ν";
                }
                {
                  trigger = ";xi;";
                  replace = "ξ";
                }
                {
                  trigger = ";Xi;";
                  replace = "Ξ";
                }
                {
                  trigger = ";omicron;";
                  replace = "ο";
                }
                {
                  trigger = ";Omicron;";
                  replace = "Ο";
                }
                {
                  trigger = ";pi;";
                  replace = "π";
                }
                {
                  trigger = ";Pi;";
                  replace = "Π";
                }
                {
                  trigger = ";rho;";
                  replace = "ρ";
                }
                {
                  trigger = ";Rho;";
                  replace = "Ρ";
                }
                {
                  trigger = ";sigma;";
                  replace = "σ";
                }
                {
                  trigger = ";Sigma;";
                  replace = "Σ";
                }
                {
                  trigger = ";tau;";
                  replace = "τ";
                }
                {
                  trigger = ";Tau;";
                  replace = "Τ";
                }
                {
                  trigger = ";upsilon;";
                  replace = "υ";
                }
                {
                  trigger = ";Upsilon;";
                  replace = "Υ";
                }
                {
                  trigger = ";phi;";
                  replace = "φ";
                }
                {
                  trigger = ";Phi;";
                  replace = "Φ";
                }
                {
                  trigger = ";chi;";
                  replace = "χ";
                }
                {
                  trigger = ";Chi;";
                  replace = "Χ";
                }
                {
                  trigger = ";psi;";
                  replace = "ψ";
                }
                {
                  trigger = ";Psi;";
                  replace = "Ψ";
                }
                {
                  trigger = ";omega;";
                  replace = "ω";
                }
                {
                  trigger = ";Omega;";
                  replace = "Ω";
                }
              ];
            };
            math = {
              matches = [
                {
                  trigger = ";forall;";
                  replace = "∀";
                }
                {
                  trigger = ";exists;";
                  replace = "∃";
                }
                {
                  trigger = ";cup;";
                  replace = "∪";
                }
                {
                  trigger = ";cap;";
                  replace = "∩";
                }
                {
                  trigger = ";land;";
                  replace = "∧";
                }
                {
                  trigger = ";lor;";
                  replace = "∨";
                }
                {
                  trigger = ";neg;";
                  replace = "¬";
                }
                {
                  trigger = ";implies;";
                  replace = "⇒";
                }
                {
                  trigger = ";iff;";
                  replace = "⇔";
                }
                {
                  trigger = ";neq;";
                  replace = "≠";
                }
                {
                  trigger = ";leq;";
                  replace = "≤";
                }
                {
                  trigger = ";geq;";
                  replace = "≥";
                }
                {
                  trigger = ";approx;";
                  replace = "≈";
                }
                {
                  trigger = ";equiv;";
                  replace = "≡";
                }
                {
                  trigger = ";in;";
                  replace = "∈";
                }
                {
                  trigger = ";notin;";
                  replace = "∉";
                }
                {
                  trigger = ";subset;";
                  replace = "⊂";
                }
                {
                  trigger = "⊂eq;";
                  replace = "⊆";
                }
                {
                  trigger = ";subseteq;";
                  replace = "⊆";
                }
                {
                  trigger = ";emptyset;";
                  replace = "∅";
                }
                {
                  trigger = ";sum;";
                  replace = "∑";
                }
                {
                  trigger = ";prod;";
                  replace = "∏";
                }
                {
                  trigger = ";int;";
                  replace = "∫";
                }
                {
                  trigger = ";partial;";
                  replace = "∂";
                }
                {
                  trigger = ";infty;";
                  replace = "∞";
                }
                {
                  trigger = ";sqrt;";
                  replace = "√";
                }
                {
                  trigger = ";pm;";
                  replace = "±";
                }
                {
                  trigger = ";times;";
                  replace = "×";
                }
                {
                  trigger = ";div;";
                  replace = "÷";
                }
                {
                  trigger = ";to;";
                  replace = "→";
                }
                {
                  trigger = ";gets;";
                  replace = "←";
                }
                {
                  trigger = ";mapsto;";
                  replace = "↦";
                }
              ];
            };
          };
        };

        systemd.user.services.espanso = lib.mkIf hyprland.enable {
          Unit = {
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
        };
      }
    ];
  };
}
