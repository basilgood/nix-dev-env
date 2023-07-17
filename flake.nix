{
  description = "development environments";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [alejandra];
      };
      web = pkgs.mkShell {
        buildInputs = with pkgs; [nodejs_20 nodePackages.typescript-language-server];
        shellHook = ''
          export PATH=$PATH:./node_modules/.bin
        '';
      };
    });
  };
}
