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
      makeHost =
        hostName: extraModules:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = extraModules ++ [
            ./nixos/system.nix
            ./hosts/${hostName}/system.nix
            home-manager.nixosModules.home-manager
            homeManagerDefaults
            {
              home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
              home-manager.users.${userName}.imports = [
                ./nixos/home.nix
                ./hosts/${hostName}/home.nix
              ];
            }
          ];
        };
      preCommitCheck =
        system:
        git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style = {
              enable = true;
              package = nixpkgs.legacyPackages.${system}.nixfmt;
            };
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

      nixosConfigurations = builtins.mapAttrs makeHost {
        MinibookXN100 = [ ];
        HX100G = [ ];
        GPDP3 = [ ];
        SurfacePro8 = [ nixos-hardware.nixosModules.microsoft-surface-pro-intel ];
      };
    };
}
