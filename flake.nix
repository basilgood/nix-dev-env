{
  description = "development environments";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
  };
  outputs =
    {
      devshell,
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ devshell.overlays.default ];
      };
    in
    {
      devShells.${system} = {
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
            nodejs_24
            nodePackages.typescript-language-server
            vscode-langservers-extracted
            yaml-language-server
            helm-ls
            vtsls
            jq
            gojq
            yamllint
            libxml2
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
              eval = "$PATH:node_modules/.bin";
            }
          ];
        };
        nvim = pkgs.devshell.mkShell {
          packages = with pkgs; [
            lua-language-server
            lua54Packages.luacheck
            tree-sitter
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
      };
    };
}
