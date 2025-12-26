{
  description = "SimpleDeck Development Shell (OpenSCAD)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      lib = pkgs.lib;
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          openscad
          openscad-lsp
        ];
      };
    };
}

