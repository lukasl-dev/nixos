{
  config,
  lib,
  atlas,
  ...
}:

let
  inherit (config) planet;

  planetTravellerType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = atlas.travellers.type;
        description = "Traveller assigned to this planet.";
      };

      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional groups granted to the traveller on this planet.";
      };
    };
  };

  planetTravellers = lib.listToAttrs (
    map (
      assignment:
      lib.nameValuePair assignment.name (
        atlas.travellers.${assignment.name}
        // {
          inherit (assignment) extraGroups;
        }
      )
    ) ([ planet.steward ] ++ planet.visitors)
  );

in
{
  options = {
    planet = {
      steward = lib.mkOption {
        type = planetTravellerType;
        default = {
          name = "prime";
          extraGroups = [
            "networkmanager"
            "wheel"
            "docker"
            "libvirtd"
            "libvirt"
            "kvm"
          ];
        };
      };

      visitors = lib.mkOption {
        type = lib.types.listOf planetTravellerType;
        default = [ ];
      };

      travellers = lib.mkOption {
        type = lib.types.listOf atlas.travellers.type;
        default = [
          planet.steward.name
        ]
        ++ map (traveller: traveller.name) planet.visitors;
        readOnly = true;
        internal = true;
      };
    };
  };

  config = {
    users.users = lib.mapAttrs' (
      _: traveller:
      lib.nameValuePair traveller.name {
        inherit (traveller) extraGroups;
      }
    ) planetTravellers;
  };
}
