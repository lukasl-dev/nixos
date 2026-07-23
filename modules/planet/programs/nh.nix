{
  config,
  atlas,
  ...
}:

let
  inherit (config) planet;

  steward = atlas.travellers.eval planet.steward.traveller;
  home = config.users.users.${steward.user.name}.home;
in
{
  programs.nh = {
    enable = true;
    flake = "${home}/nixos";

    clean = {
      enable = true;
      extraArgs = "--keep-since 4d --keep 3";
    };
  };
}
