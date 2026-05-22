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

  outputs = { self, nixpkgs, home-manager, plasma-manager, nix-darwin, ... }@inputs:
    let
      userName = "wantjoy";
      specialArgs = { inherit userName; };
      systemDefaults = {
        nixpkgs.config.allowUnfree = true;
        nix.settings.experimental-features = [ "nix-command" "flakes" ];
      };
      homeManagerDefaults = {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          extraSpecialArgs = specialArgs;
        };
      };
    in {
      nixosConfigurations.MinibookXN100 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;
        modules = [
          systemDefaults
          ./modules/nixos/common.nix
          ./hosts/MinibookXN100/configuration.nix
          home-manager.nixosModules.home-manager
          homeManagerDefaults
          {
            home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
            home-manager.users.${userName} = import ./home/nixos.nix;
          }
        ];
      };

      nixosConfigurations.HX100G = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;
        modules = [
          systemDefaults
          ./hosts/HX100G/configuration.nix
          home-manager.nixosModules.home-manager
          homeManagerDefaults
          {
            home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
            home-manager.users.${userName} = import ./home/nixos.nix;
          }
        ];
      };

      darwinConfigurations.MBA = nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        modules = [
          systemDefaults
          ./hosts/MBA/configuration.nix
          { nixpkgs.hostPlatform = "aarch64-darwin"; }
          home-manager.darwinModules.home-manager
          homeManagerDefaults
          { home-manager.users.${userName} = import ./home/darwin.nix; }
        ];
      };
    };
}
