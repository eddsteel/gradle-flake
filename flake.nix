{
  description = "Gradle project";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = { self, nixpkgs, ... }: let
    javaVersionFile = f: with nixpkgs.lib; removeSuffix "\n" (readFile f);
    javaP = pkgs: v : pkgs."openjdk${v}_headless";
    gradlePkgs = let
      gradleVersions = with builtins; fromJSON (readFile ./gradle.json);
      gradleP = pkgs: gv: jv: pkgs.callPackage (pkgs.gradle-packages.gen {
        defaultJava = (javaP pkgs jv);
        inherit (gradleVersions."${gv}") version nativeVersion sha256;
      }) {};
    in pkgs: args: [
      (gradleP pkgs args.gradleVersion args.javaVersion)
      (javaP pkgs args.javaVersion)
    ];
    defaultArgs = {
      javaVersion = "19";
      gradleVersion = "8";
    };
    shell = system: args: let
      pkgs = import nixpkgs { inherit system; };
    in pkgs.mkShell {
      packages = gradlePkgs pkgs (defaultArgs // args);
    };
  in {
    lib = {
      inherit javaVersionFile shell;
    };
    templates = {
      latest = {
        path = ./examples/latest;
        description = "A flake using latest Java and Gradle.";
      };
      java-version = {
        path = ./examples/java-version;
        description = "A flake using the latest Gradle and Java major version from `./.java-version`.";
      };
      custom = {
        path = ./examples/custom;
        description = "A flake using a custom Gradle and Java major version.";
      };
    };
    defaultTemplate = self.templates.java-version;
  };
}
