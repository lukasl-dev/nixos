{
  meta,
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  imports = [ ../../presets/desktop/nixos ];

  home-manager.users.${meta.user.name} = import ./home {
    inherit inputs pkgs pkgs-unstable;
  };
}
