{
  atlas,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.programs) espanso;

  package = pkgs.espanso-wayland;
  yaml = pkgs.formats.yaml { };

  matches = pairs: {
    matches = map (pair: {
      trigger = builtins.elemAt pair 0;
      replace = builtins.elemAt pair 1;
    }) pairs;
  };

  writing = matches [
    [
      ";emdash;"
      "—"
    ]
    [
      ";ae;"
      "ä"
    ]
    [
      ";Ae;"
      "Ä"
    ]
    [
      ";oe;"
      "ö"
    ]
    [
      ";Oe;"
      "Ö"
    ]
    [
      ";ue;"
      "ü"
    ]
    [
      ";Ue;"
      "Ü"
    ]
    [
      ";ss;"
      "ß"
    ]
  ];

  greek = matches (
    lib.concatMap
      (symbol: [
        [
          ";${symbol.name};"
          symbol.lower
        ]
        [
          ";${lib.toSentenceCase symbol.name};"
          symbol.upper
        ]
      ])
      [
        {
          name = "alpha";
          lower = "α";
          upper = "Α";
        }
        {
          name = "beta";
          lower = "β";
          upper = "Β";
        }
        {
          name = "gamma";
          lower = "γ";
          upper = "Γ";
        }
        {
          name = "delta";
          lower = "δ";
          upper = "Δ";
        }
        {
          name = "epsilon";
          lower = "ε";
          upper = "Ε";
        }
        {
          name = "zeta";
          lower = "ζ";
          upper = "Ζ";
        }
        {
          name = "eta";
          lower = "η";
          upper = "Η";
        }
        {
          name = "theta";
          lower = "θ";
          upper = "Θ";
        }
        {
          name = "iota";
          lower = "ι";
          upper = "Ι";
        }
        {
          name = "kappa";
          lower = "κ";
          upper = "Κ";
        }
        {
          name = "lambda";
          lower = "λ";
          upper = "Λ";
        }
        {
          name = "mu";
          lower = "μ";
          upper = "Μ";
        }
        {
          name = "nu";
          lower = "ν";
          upper = "Ν";
        }
        {
          name = "xi";
          lower = "ξ";
          upper = "Ξ";
        }
        {
          name = "omicron";
          lower = "ο";
          upper = "Ο";
        }
        {
          name = "pi";
          lower = "π";
          upper = "Π";
        }
        {
          name = "rho";
          lower = "ρ";
          upper = "Ρ";
        }
        {
          name = "sigma";
          lower = "σ";
          upper = "Σ";
        }
        {
          name = "tau";
          lower = "τ";
          upper = "Τ";
        }
        {
          name = "upsilon";
          lower = "υ";
          upper = "Υ";
        }
        {
          name = "phi";
          lower = "φ";
          upper = "Φ";
        }
        {
          name = "chi";
          lower = "χ";
          upper = "Χ";
        }
        {
          name = "psi";
          lower = "ψ";
          upper = "Ψ";
        }
        {
          name = "omega";
          lower = "ω";
          upper = "Ω";
        }
      ]
  );

  math = matches [
    [
      ";N;"
      "ℕ"
    ]
    [
      ";Z;"
      "ℤ"
    ]
    [
      ";Q;"
      "ℚ"
    ]
    [
      ";R;"
      "ℝ"
    ]
    [
      ";C;"
      "ℂ"
    ]
    [
      ";forall;"
      "∀"
    ]
    [
      ";exists;"
      "∃"
    ]
    [
      ";cup;"
      "∪"
    ]
    [
      ";cap;"
      "∩"
    ]
    [
      ";land;"
      "∧"
    ]
    [
      ";lor;"
      "∨"
    ]
    [
      ";neg;"
      "¬"
    ]
    [
      ";implies;"
      "⇒"
    ]
    [
      ";iff;"
      "⇔"
    ]
    [
      ";neq;"
      "≠"
    ]
    [
      ";leq;"
      "≤"
    ]
    [
      ";geq;"
      "≥"
    ]
    [
      ";approx;"
      "≈"
    ]
    [
      ";equiv;"
      "≡"
    ]
    [
      ";in;"
      "∈"
    ]
    [
      ";notin;"
      "∉"
    ]
    [
      ";subset;"
      "⊂"
    ]
    [
      "⊂eq;"
      "⊆"
    ]
    [
      ";subseteq;"
      "⊆"
    ]
    [
      ";emptyset;"
      "∅"
    ]
    [
      ";sum;"
      "∑"
    ]
    [
      ";prod;"
      "∏"
    ]
    [
      ";int;"
      "∫"
    ]
    [
      ";partial;"
      "∂"
    ]
    [
      ";infty;"
      "∞"
    ]
    [
      ";sqrt;"
      "√"
    ]
    [
      ";pm;"
      "±"
    ]
    [
      ";times;"
      "×"
    ]
    [
      ";div;"
      "÷"
    ]
    [
      ";to;"
      "→"
    ]
    [
      ";gets;"
      "←"
    ]
    [
      ";mapsto;"
      "↦"
    ]
  ];

  files = {
    "espanso/config/default.yml".source = yaml.generate "espanso-config.yml" {
      keyboard_layout.layout = "us";
    };
    "espanso/match/writing.yml".source =
      yaml.generate "espanso-writing.yml" writing;
    "espanso/match/greek.yml".source = yaml.generate "espanso-greek.yml" greek;
    "espanso/match/math.yml".source = yaml.generate "espanso-math.yml" math;
  };
in
{
  options.planet.programs.espanso.enable = lib.mkEnableOption "Espanso" // {
    default = planet.desktop.enable;
    defaultText = lib.literalExpression "config.planet.desktop.enable";
  };

  config = lib.mkIf espanso.enable {
    planet.roles.visitor.groups = [
      "input"
      "uinput"
    ];

    hardware.uinput.enable = true;

    environment.systemPackages = [ package ];

    hjem.users = atlas.travellers.forEach planet (_: {
      xdg.config.files = files;
    });

    systemd.user.services.espanso = {
      description = "Espanso text expander";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";

      serviceConfig = {
        ExecStart = "${lib.getExe package} launcher";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
