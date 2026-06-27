{
  description = "Personal Nix configurations for NixOS and macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    herdr = {
      url = "github:ogulcancelik/herdr/v0.7.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, plasma-manager, nix-darwin, herdr, ... }@inputs:
    let
      userName = "wantjoy";
      specialArgs = { inherit userName herdr; };
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
          ./base/system.nix
          ./nixos/system.nix
          ./hosts/MinibookXN100/system.nix
          home-manager.nixosModules.home-manager
          homeManagerDefaults
          {
            home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
            home-manager.users.${userName}.imports = [
              ./base/home.nix
              ./nixos/home.nix
              ./hosts/MinibookXN100/home.nix
            ];
          }
        ];
      };

      nixosConfigurations.HX100G = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;
        modules = [
          ./base/system.nix
          ./nixos/system.nix
          ./hosts/HX100G/system.nix
          home-manager.nixosModules.home-manager
          homeManagerDefaults
          {
            home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
            home-manager.users.${userName}.imports = [
              ./base/home.nix
              ./nixos/home.nix
              ./hosts/HX100G/home.nix
            ];
          }
        ];
      };

      nixosConfigurations.GPDP3 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;
        modules = [
          ./base/system.nix
          ./nixos/system.nix
          ./hosts/GPDP3/system.nix
          home-manager.nixosModules.home-manager
          homeManagerDefaults
          {
            home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
            home-manager.users.${userName}.imports = [
              ./base/home.nix
              ./nixos/home.nix
              ./hosts/GPDP3/home.nix
            ];
          }
        ];
      };

      nixosConfigurations.SurfacePro8 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;
        modules = [
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
          ./base/system.nix
          ./nixos/system.nix
          ./hosts/SurfacePro8/system.nix
          home-manager.nixosModules.home-manager
          homeManagerDefaults
          {
            home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
            home-manager.users.${userName}.imports = [
              ./base/home.nix
              ./nixos/home.nix
              ./hosts/SurfacePro8/home.nix
            ];
          }
        ];
      };

      darwinConfigurations.MBA = nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        modules = [
          ./base/system.nix
          ./hosts/MBA/system.nix
          { nixpkgs.hostPlatform = "aarch64-darwin"; }
          home-manager.darwinModules.home-manager
          homeManagerDefaults
          {
            home-manager.users.${userName}.imports = [
              ./base/home.nix
              ./darwin/home.nix
            ];
          }
        ];
      };
    };
}
