{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";

      overlay = import ./overlay.nix;
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay.overlay ];
      };

      myLib = import ./lib { lib = pkgs.lib; };
      modules = myLib.loadModules {
        inherit inputs;
      };
    in
    {
      inherit modules;
      nixosConfigurations = {
        meow = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system inputs;
            hostName = "meow";
          };

          modules = [
            ./hosts/meow/configuration.nix
          ];
        };
      };

      agenix-rekey = inputs.agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = self.nixosConfigurations;
      };

      overlays.default = overlay.overlay;
      packages.${system} = builtins.listToAttrs (
        map (name: {
          inherit name;
          value = pkgs.${name};
        }) overlay.packageNames
      );
    };
}
