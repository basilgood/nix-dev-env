{
  description = "development environments";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
            nixfmt
            nixd
            nil
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
            docker-language-server
            helm-ls
            vtsls
            jq
            yamllint
            libxml2
            shfmt
            shellcheck
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
      packages.${system} = {
        flattenc = pkgs.writeShellApplication {
          name = "autofollowc";
          text = "exec nix run github:fzakaria/nix-auto-follow -- -c flake.lock \"$@\"";
        };
        flatteni = pkgs.writeShellApplication {
          name = "autofollowi";
          text = "exec nix run github:fzakaria/nix-auto-follow -- -i flake.lock \"$@\"";
        };
      };
    };
}
