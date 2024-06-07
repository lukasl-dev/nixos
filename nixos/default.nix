{ withSystem, self, inputs, ... }:

{
  flake.nixosConfigurations = {
    vega = withSystem "x86_64-linux" (
      {
        self',
        ...
      }:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs self';
        };
        modules = [
          ./vega
          self.nixosModules.polkit-gnome
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.lukas = import ../home;
              extraSpecialArgs = {
                inherit inputs self';
              };
            };
          }
        ];
      }
    );
  };
}
