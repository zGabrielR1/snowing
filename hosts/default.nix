{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = let
    inherit (inputs.nixpkgs.lib) nixosSystem;
    mod = "${self}/system";

    specialArgs = { inherit inputs self; };

  in {
    homeConfig = nixosSystem {
      inherit specialArgs;
      modules = [
        # Import the ./laptop module
        ./laptop

        # Add the Home Manager configuration
        {
          home-manager = {
              users.linuxmobile.imports =
                homeImports."zrrg@laptop";
              extraSpecialArgs = specialArgs;
            };
            extraSpecialArgs = specialArgs;
          };
        }
      ];
    };
  };
}
