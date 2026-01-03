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

      pkgs = import nixpkgs {
        inherit system;
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
            noctalia = inputs.noctalia;
            hostName = "meow";
          };

          modules = [
            ./nixos/configuration.nix
          ];
        };
      };

      agenix-rekey = inputs.agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = self.nixosConfigurations;
        # Example for colmena:
        # nixosConfigurations = ((colmena.lib.makeHive self.colmena).introspect (x: x)).nodes;
      };
    };
}
