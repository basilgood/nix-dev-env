{
  description = "development environments";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
  };
  outputs =
    {
      self,
      nixpkgs,
      devshell,
    }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ devshell.overlays.default ];
        }
      );
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.devshell.mkShell {
            packages = with pkgs; [
              nixfmt-rfc-style
              nixd
            ];
            env = [
              {
                name = "DEVSHELL_NO_MOTD";
                value = 1;
              }
            ];
          };
          web = pkgs.devshell.mkShell {
            packages = with pkgs; [
              nodejs_22
              nodePackages.typescript-language-server
              vscode-langservers-extracted
              vtsls
              jq
              yamllint
              shfmt
              azure-storage-azcopy
            ];
            env = [
              {
                name = "DEVSHELL_NO_MOTD";
                value = 1;
              }
              {
                name = "PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS";
                value = 1;
              }
              {
                name = "PATH";
                prefix = "node_modules/.bin";
              }
            ];
          };
          nvim = pkgs.devshell.mkShell {
            packages = with pkgs; [
              lua-language-server
              lua54Packages.luacheck
              stylua
              gcc
              gnumake
            ];
            env = [
              {
                name = "DEVSHELL_NO_MOTD";
                value = 1;
              }
            ];
          };
          rust = pkgs.devshell.mkShell {
            name = "rust";
            imports = [ "${devshell}/extra/language/rust.nix" ];
            packages = with pkgs; [ rust-analyzer ];
            env = [
              {
                name = "RUST_BACKTRACE";
                value = "1";
              }
            ];
          };
        }
      );
    };
}
