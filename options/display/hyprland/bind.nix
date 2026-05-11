{
  config,
  lib,
  ...
}:

let
  inherit (config.planet.display) hyprland;

  valueType =
    with lib.types;
    nullOr (oneOf [
      bool
      int
      float
      str
      path
      (attrsOf valueType)
      (listOf valueType)
    ]);

  methods = {
    general = [
      "exec_raw"
      "focus"
      "exit"
      "submap"
      "pass"
      "send_shortcut"
      "send_key_state"
      "layout"
      "dpms"
      "event"
      "global"
      "force_idle"
      "no_op"
    ];

    window = [
      "close"
      "kill"
      "signal"
      "float"
      "fullscreen"
      "fullscreen_state"
      "pseudo"
      "move"
      "swap"
      "center"
      "cycle_next"
      "tag"
      "clear_tags"
      "toggle_swallow"
      "pin"
      "alter_zorder"
      "set_prop"
      "deny_from_group"
      "drag"
      "resize"
    ];

    workspace = [
      "rename"
      "move"
      "swap_monitors"
      "toggle_special"
    ];

    group = [
      "toggle"
      "next"
      "prev"
      "active"
      "move_window"
      "lock"
      "lock_active"
    ];

    cursor = [
      "move_to_corner"
      "move"
    ];
  };

  categories = builtins.attrNames methods;

  categoryOption =
    category:
    lib.mkOption {
      type = lib.types.attrsOf valueType;
      default = { };
      example = {
        close = null;
        float = { };
      };
      description = "${category} dispatchers. Keys must be valid hl.dsp.${
        lib.optionalString (category != "general") "${category}."
      }<method> names.";
    };

  dispatcherLeaves =
    dispatcher:
    lib.concatMap (
      category:
      map (name: {
        inherit category name;
        value = dispatcher.${category}.${name};
      }) (builtins.attrNames dispatcher.${category})
    ) categories;

  dispatcherChoices =
    dispatcher:
    lib.optional (dispatcher.lua != null) dispatcher.lua
    ++ lib.optional (dispatcher.execCmd != null) dispatcher.execCmd
    ++ dispatcherLeaves dispatcher;

  unknownMethods =
    dispatcher:
    builtins.filter (leaf: !(builtins.elem leaf.name methods.${leaf.category})) (
      dispatcherLeaves dispatcher
    );

  showMethod =
    leaf: if leaf.category == "general" then leaf.name else "${leaf.category}.${leaf.name}";

  toLua = lib.generators.toLua { };
  renderArg = value: if value == null then "" else toLua value;
  renderLeaf =
    leaf:
    let
      prefix = lib.optionalString (leaf.category != "general") "${leaf.category}.";
    in
    "hl.dsp.${prefix}${leaf.name}(${renderArg leaf.value})";

  renderDispatcher =
    bind:
    let
      dispatcher = bind.dispatcher;
      leaves = dispatcherLeaves dispatcher;
    in
    if dispatcher.execCmd != null then
      "hl.dsp.exec_cmd(${builtins.toJSON dispatcher.execCmd})"
    else if dispatcher.lua != null then
      dispatcher.lua
    else if leaves != [ ] then
      renderLeaf (builtins.head leaves)
    else
      "nil";

  bind = keys: dispatcher: { inherit keys dispatcher; };
  dsp = category: method: value: { ${category}.${method} = value; };
  general = dsp "general";
  window = dsp "window";
  workspace = dsp "workspace";

  expand =
    mods: keys: dispatcher:
    lib.concatMap (mod: map (key: bind "${mod} + ${key}" dispatcher) keys) mods;

  windowMods = [
    "SUPER"
    "ALT"
  ];

  windowShiftMods = [
    "SUPER + SHIFT"
    "ALT + SHIFT"
  ];

  workspaceKeys = map (workspace: {
    inherit workspace;
    key = if workspace == "10" then "0" else workspace;
  }) (map builtins.toString (lib.range 1 10));

  defaultBinds = [
    (bind "SUPER + Q" (workspace "toggle_special" "special"))
    (bind "SUPER + SHIFT + Q" (window "move" { workspace = "special"; }))
  ]
  ++ expand windowMods [ "V" ] (window "float" { })
  ++ expand windowMods [ "V" ] (window "center" { })
  ++ expand windowShiftMods [ "H" ] (general "layout" "swapcol l")
  ++ expand windowShiftMods [ "L" ] (general "layout" "swapcol r")
  ++ expand windowMods [ "N" ] (window "swap" { next = true; })
  ++ expand windowMods [ "F" ] (window "pseudo" { })
  ++ expand windowMods [ "W" ] (window "close" null)
  ++ expand windowMods [ "M" ] (window "fullscreen" { mode = "maximized"; })
  ++ expand windowShiftMods [ "M" ] (window "fullscreen" { })
  ++ expand windowMods [ "h" ] (general "layout" "focus l")
  ++ expand windowMods [ "l" ] (general "layout" "focus r")
  ++ expand windowMods [ "k" ] (general "focus" { direction = "u"; })
  ++ expand windowMods [ "j" ] (general "focus" { direction = "d"; })
  ++ lib.concatMap (
    w: expand windowMods [ w.key ] (general "focus" { inherit (w) workspace; })
  ) workspaceKeys
  ++ lib.concatMap (
    w: expand windowShiftMods [ w.key ] (window "move" { inherit (w) workspace; })
  ) workspaceKeys
  ++ expand windowMods [ "mouse_down" ] (general "focus" { workspace = "e+1"; })
  ++ expand windowMods [ "mouse_up" ] (general "focus" { workspace = "e-1"; })
  ++ expand windowMods [ "comma" ] (general "layout" "move -col")
  ++ expand windowMods [ "period" ] (general "layout" "move +col")
  ++ expand [ "SUPER + ALT" ] [ "minus" ] (general "layout" "colresize -0.1")
  ++ expand [ "SUPER + ALT" ] [ "equal" ] (general "layout" "colresize +0.1")
  ++ expand windowMods [ "minus" ] (general "layout" "colresize -conf")
  ++ expand windowMods [ "equal" ] (general "layout" "colresize +conf");
in
{
  options.planet.display.hyprland.bind = lib.mkOption {
    type =
      with lib.types;
      listOf (submodule {
        options = {
          keys = lib.mkOption {
            type = str;
            example = "SUPER + Q";
            description = "Hyprland bind keys.";
          };

          dispatcher = {
            lua = lib.mkOption {
              type = nullOr lines;
              default = null;
              example = # lua
                ''hl.dsp.exec_cmd("firefox")'';
              description = "Lua dispatcher expression passed as second argument to hl.bind.";
            };

            execCmd = lib.mkOption {
              type = nullOr str;
              default = null;
              example = "firefox";
              description = "Command to execute via hl.dsp.exec_cmd.";
            };

            general = categoryOption "general";
            window = categoryOption "window";
            workspace = categoryOption "workspace";
            group = categoryOption "group";
            cursor = categoryOption "cursor";
          };
        };
      });
    default = [ ];
    example = [
      {
        keys = "SUPER + Return";
        dispatcher.execCmd = "ghostty";
      }
      {
        keys = "SUPER, Q";
        dispatcher.window.close = null;
      }
      {
        keys = "SUPER, V";
        dispatcher.window.float = { };
      }
      {
        keys = "SUPER, 1";
        dispatcher.general.focus = {
          workspace = "1";
        };
      }
      {
        keys = "SUPER, X";
        dispatcher.lua = # lua
          ''
            function()
              hl.dispatch(hl.dsp.no_op())
            end
          '';
      }
    ];
    description = "Hyprland binds generated as hl.bind(keys, dispatcher).";
  };

  config = lib.mkIf hyprland.enable {
    assertions = lib.concatMap (
      bind:
      let
        unknown = unknownMethods bind.dispatcher;
      in
      [
        {
          assertion = builtins.length (dispatcherChoices bind.dispatcher) == 1;
          message = "🪐 Hyprland bind '${bind.keys}' must define exactly one dispatcher.";
        }
        {
          assertion = unknown == [ ];
          message = "🪐 Hyprland bind '${bind.keys}' has unknown dispatcher methods: ${lib.concatStringsSep ", " (map showMethod unknown)}.";
        }
      ]
    ) hyprland.bind;

    planet.display.hyprland = {
      bind = defaultBinds;
      lua = map (bind: ''
        hl.bind(${builtins.toJSON bind.keys}, ${renderDispatcher bind})
      '') hyprland.bind;
    };
  };
}
