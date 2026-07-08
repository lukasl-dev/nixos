{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "taman";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "harmoneer";
    repo = "taman";
    # Upstream has no tags/releases, so pin to the latest master commit.
    rev = "0a7c7d7a5a8ed1e85a51d4043cb6810124fe8ca5";
    hash = "sha256-4OmMR084Ie4yZ2qjaZvCQBLKwcllAsLoh3xZDx0WAIE=";
  };

  cargoHash = "sha256-BYFPICGoxjMGiyJ3GAyTg0CaLNV5ZMOM1n+mCNI+oFE=";

  # Pure TUI app with no native build inputs beyond the Rust toolchain.
  doCheck = false;

  meta = {
    description = "TUI Pomodoro productivity app where focus sessions grow plants";
    homepage = "https://github.com/harmoneer/taman";
    license = lib.licenses.mit;
    mainProgram = "taman";
    platforms = lib.platforms.unix;
  };
})
