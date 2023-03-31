{
  description = "Gradle Shell";

  inputs.gradle.url = "github:eddsteel/gradle-flake";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, gradle, flake-utils }:
    flake-utils.lib.eachDefaultSystem (sys: { devShells.default = gradle.lib.shell sys {}; });
}
