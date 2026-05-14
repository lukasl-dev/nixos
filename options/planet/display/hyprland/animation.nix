{
  config,
  lib,
  ...
}:

let
  inherit (config.planet.display) hyprland;
  inherit (lib.types)
    listOf
    attrsOf
    bool
    float
    str
    nullOr
    submodule
    oneOf
    int
    ;

  toLua = lib.generators.toLua { };
  numberType = oneOf [
    int
    float
  ];
  pointType = listOf numberType;

  curveType = submodule {
    options = {
      type = lib.mkOption {
        type = str;
        example = "bezier";
        description = "Curve type: 'bezier' or 'spring'.";
      };
      points = lib.mkOption {
        type = listOf pointType;
        default = [ ];
        description = "Bezier control points.";
      };
      mass = lib.mkOption {
        type = nullOr numberType;
        default = null;
        description = "Spring mass.";
      };
      stiffness = lib.mkOption {
        type = nullOr numberType;
        default = null;
        description = "Spring stiffness.";
      };
      dampening = lib.mkOption {
        type = nullOr numberType;
        default = null;
        description = "Spring dampening.";
      };
    };
  };

  animationType = submodule {
    options = {
      leaf = lib.mkOption {
        type = str;
        example = "windows";
        description = "Animation leaf name.";
      };
      enabled = lib.mkOption {
        type = bool;
        default = true;
        description = "Whether the animation is enabled.";
      };
      speed = lib.mkOption {
        type = nullOr numberType;
        default = null;
        description = "Animation speed.";
      };
      bezier = lib.mkOption {
        type = nullOr str;
        default = null;
        description = "Bezier curve name.";
      };
      spring = lib.mkOption {
        type = nullOr str;
        default = null;
        description = "Spring curve name.";
      };
      style = lib.mkOption {
        type = nullOr str;
        default = null;
        description = "Animation style, e.g. 'popin 80%'.";
      };
    };
  };

  renderCurve =
    name: curve:
    let
      opts = lib.filterAttrs (_: v: v != null) {
        inherit (curve)
          type
          points
          mass
          stiffness
          dampening
          ;
      };
    in
    "hl.curve(${toLua name}, ${toLua opts})";

  renderAnimation =
    anim:
    let
      opts = lib.filterAttrs (_: v: v != null) {
        inherit (anim)
          leaf
          enabled
          speed
          bezier
          spring
          style
          ;
      };
    in
    "hl.animation(${toLua opts})";
in
{
  options.planet.display.hyprland = {
    curves = lib.mkOption {
      type = attrsOf curveType;
      default = {
        myBezier = {
          type = "bezier";
          points = [
            [
              0.05
              0.9
            ]
            [
              0.1
              1.05
            ]
          ];
        };
      };
      description = "Animation curves passed to hl.curve.";
    };

    animations = lib.mkOption {
      type = listOf animationType;
      default = [
        {
          leaf = "windows";
          speed = 7;
          bezier = "myBezier";
        }
        {
          leaf = "windowsOut";
          speed = 7;
          bezier = "default";
          style = "popin 80%";
        }
        {
          leaf = "border";
          speed = 10;
          bezier = "default";
        }
        {
          leaf = "borderangle";
          speed = 8;
          bezier = "default";
        }
        {
          leaf = "fade";
          speed = 7;
          bezier = "default";
        }
        {
          leaf = "workspaces";
          speed = 6;
          bezier = "default";
        }
      ];
      description = "Animation declarations passed to hl.animation.";
    };
  };

  config = lib.mkIf hyprland.enable {
    planet.display.hyprland.lua =
      lib.mapAttrsToList renderCurve hyprland.curves ++ map renderAnimation hyprland.animations;
  };
}
