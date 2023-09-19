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
        buildInputs = with pkgs; [alejandra nil statix];
      };
      web = pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs_20
          nodePackages_latest.typescript-language-server
          jq
          yamlfix
          yamllint
          shfmt
        ];
        shellHook = ''
          export PATH=$PATH:./node_modules/.bin
        '';
      };
      vim = pkgs.mkShell {
        buildInputs = with pkgs; [nodejs_20 nodePackages_latest.vim-language-server];
      };
      nvim = pkgs.mkShell {
        buildInputs = with pkgs; [lua54Packages.luacheck stylua];
      };
    });
  };
}
