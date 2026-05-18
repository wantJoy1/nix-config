{
  description = "Personal Nix configurations for NixOS and macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, nix-darwin, ... }@inputs: {
    nixosConfigurations.MinibookXN100 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/MinibookXN100/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.sharedModules = [
            plasma-manager.homeModules.plasma-manager
          ];
          home-manager.users.kf = import ./home.nix;
        }
      ];
    };

    darwinConfigurations.MBA = nix-darwin.lib.darwinSystem {
      modules = [
        ./hosts/MBA/configuration.nix
        { nixpkgs.hostPlatform = "aarch64-darwin"; }
      ];
    };
  };
}
