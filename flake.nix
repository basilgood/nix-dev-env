{
  description = "development environments";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    linear-term = {
      url = "github:tjburch/linear-term";
      flake = false;
    };
  };
  outputs =
    {
      nixpkgs,
      linear-term,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      pythonPackages = pkgs.python3Packages;
    in
    {
      devShells.${system} = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt
            nixd
            nil
          ];
        };

        web = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_24
            nodePackages.typescript-language-server
            vscode-langservers-extracted
            yaml-language-server
            helm-ls
            vtsls
            jq
            yamllint
            hadolint
            dockerfmt
            libxml2
            shfmt
            shellcheck
            azure-storage-azcopy
          ];

          PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "1";

          shellHook = ''
            export PATH="$PATH:node_modules/.bin"
          '';
        };

        nvim = pkgs.mkShell {
          packages = with pkgs; [
            lua-language-server
            lua54Packages.luacheck
            tree-sitter
            stylua
            gcc
            gnumake
          ];
        };

        rust = pkgs.mkShell {
          packages = with pkgs; [
            cargo
            rustc
            rustfmt
            clippy
            rust-analyzer
          ];

          RUST_BACKTRACE = "1";
        };

        linear-term = pkgs.mkShell {
          packages = [
            (pkgs.python3.withPackages (
              p: with p; [
                textual
                httpx
                gql
                pyyaml
                platformdirs
                rich
              ]
            ))
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
        linear-term = pythonPackages.buildPythonApplication {
          pname = "linear-term";
          version = "0.1.0";
          format = "pyproject";
          src = linear-term;
          nativeBuildInputs = with pythonPackages; [
            hatchling
          ];
          propagatedBuildInputs = with pythonPackages; [
            textual
            httpx
            gql
            pyyaml
            platformdirs
            rich
          ];
        };
      };
    };
}
