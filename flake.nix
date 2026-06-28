{
  description = "Personal Nix configurations for NixOS";

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
    herdr = {
      url = "github:ogulcancelik/herdr/v0.7.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixos-hardware,
      home-manager,
      plasma-manager,
      herdr,
      git-hooks,
      ...
    }:
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
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
      preCommitCheck =
        system:
        git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style.enable = true;
            statix.enable = true;
            deadnix = {
              enable = true;
              excludes = [ "hosts/.*/hardware\\.nix$" ];
            };
          };
        };
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      checks = forAllSystems (system: {
        pre-commit = preCommitCheck system;
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pre-commit = preCommitCheck system;
        in
        {
          default = pkgs.mkShell {
            inherit (pre-commit) shellHook;
            packages = pre-commit.enabledPackages ++ [
              pkgs.deno
              pkgs.web-ext
            ];
          };
        }
      );

      nixosConfigurations = {
        MinibookXN100 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./nixos/system.nix
            ./hosts/MinibookXN100/system.nix
            home-manager.nixosModules.home-manager
            homeManagerDefaults
            {
              home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
              home-manager.users.${userName}.imports = [
                ./nixos/home.nix
                ./hosts/MinibookXN100/home.nix
              ];
            }
          ];
        };

        HX100G = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./nixos/system.nix
            ./hosts/HX100G/system.nix
            home-manager.nixosModules.home-manager
            homeManagerDefaults
            {
              home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
              home-manager.users.${userName}.imports = [
                ./nixos/home.nix
                ./hosts/HX100G/home.nix
              ];
            }
          ];
        };

        GPDP3 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./nixos/system.nix
            ./hosts/GPDP3/system.nix
            home-manager.nixosModules.home-manager
            homeManagerDefaults
            {
              home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
              home-manager.users.${userName}.imports = [
                ./nixos/home.nix
                ./hosts/GPDP3/home.nix
              ];
            }
          ];
        };

        SurfacePro8 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            nixos-hardware.nixosModules.microsoft-surface-pro-intel
            ./nixos/system.nix
            ./hosts/SurfacePro8/system.nix
            home-manager.nixosModules.home-manager
            homeManagerDefaults
            {
              home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
              home-manager.users.${userName}.imports = [
                ./nixos/home.nix
                ./hosts/SurfacePro8/home.nix
              ];
            }
          ];
        };
      };
    };
}
