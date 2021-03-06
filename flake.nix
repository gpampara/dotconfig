{
  description = "macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    emacs-overlay.url = "github:nix-community/emacs-overlay/master";
    home-manager = {
      url = "github:rycee/home-manager/master";
      inputs.nixpkgs.follows = "/nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur, home-manager, emacs-overlay, ... }:
    let
      system = "x86_64-darwin";
    in
    {
      homeManagerConfigurations = {
        gpampara = home-manager.lib.homeManagerConfiguration {
          configuration = { ... }: {
            nixpkgs.overlays = [
              (import ./overlays)
              emacs-overlay.overlay
              nur.overlay
            ];
            imports =
              let
                nur-no-pkgs = import nur {
                  nurpkgs = import nixpkgs {
                    inherit system;
                  };
                };
              in
              [
                nur-no-pkgs.repos.rycee.hmModules.emacs-init
                ./home.nix
              ];
          };

          inherit system;
          homeDirectory = /Users/gpampara;
          username = "gpampara";
        };
      };
    };
}
