{
  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = {
    self,
    nixpkgs,
    devenv,
    systems,
    ...
  } @ inputs: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    packages = forEachSystem (system: {
      devenv-up = self.devShells.${system}.default.config.procfileScript;
      devenv-test = self.devShells.${system}.default.config.test;
    });

    devShells =
      forEachSystem
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              languages.python = {
                enable = true;
                venv = {
                  enable = true;
                  requirements = ''
                    taskw==2.0.0
                    inquirer==3.1.4
                    colorama==0.4.6
                    termcolor==1.1.0
                    python-dateutil==2.8.2
                    pytz==2022.7.1
                    questionary==2.0.1
                    texttable==1.6.7
                    pandas==1.5.3
                    rich==13.7.0
                    fuzzywuzzy
                    python-Levenshtein
                  '';
                };
              };
            }
          ];
        };
      });
  };
}
