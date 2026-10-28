{
  description = "Home Manager configuration with Flakes";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "aarch64-linux"; # Change to "aarch64-linux" if on an ARM machine
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."chander" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here
        modules = [ ./home.nix ];
      };
    };
}
