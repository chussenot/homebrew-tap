# Rendered by scripts/homebrew-formula.sh in github.com/chussenot/judgment on
# each release; edit that script, not this file. The tarballs are the GitHub
# release's, built on native runners and checked before they were packaged
# (docs/cli.md); each has a build-provenance attestation:
#   gh attestation verify jud-v0.10.2-<triple>.tar.gz --repo chussenot/judgment
class Jud < Formula
  desc "Evaluate JSON against a .jud rubric with a calibrated System One model"
  homepage "https://github.com/chussenot/judgment"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  # Intel macOS has no release tarball (no native runner builds one); it
  # installs from crates.io: cargo install judgment --features cli
  on_macos do
    depends_on arch: :arm64
    on_arm do
      url "https://github.com/chussenot/judgment/releases/download/v0.10.2/jud-v0.10.2-aarch64-apple-darwin.tar.gz"
      sha256 "503eb674be9715032d5f7700bf225f871af6377f1d65195f6c9633a2d3269d0e"
    end
  end

  # Statically linked (musl): any distribution, glibc or not.
  on_linux do
    on_arm do
      url "https://github.com/chussenot/judgment/releases/download/v0.10.2/jud-v0.10.2-aarch64-unknown-linux-musl.tar.gz"
      sha256 "f6ba1ec899f230b1d376c60faa99e67a0f8258d68b36cde03029f0b48413a538"
    end
    on_intel do
      url "https://github.com/chussenot/judgment/releases/download/v0.10.2/jud-v0.10.2-x86_64-unknown-linux-musl.tar.gz"
      sha256 "48fde3b58efde2c6428fd0dff0c5d9966b8375bca5d03b3aaf176ff8b60c5027"
    end
  end

  def install
    bin.install "jud"
    doc.install "README.md", "CHANGELOG.md"
    # `jud completion <shell>` prints the script clap derives from the
    # command tree, so it cannot drift from the binary.
    generate_completions_from_executable(bin/"jud", "completion")
  end

  test do
    assert_match "jud #{version}", shell_output("#{bin}/jud --version")
    # A document the binary reads the way the crate does: a minimal Rubric
    # in the envelope the format takes (jud/v1.3), accepted with status 0.
    (testpath/"ok.jud").write <<~YAML
      apiVersion: jud/v1.3
      kind: Rubric
      metadata:
        name: ok
      spec:
        questions:
          fine:
            type: noul
            instructions: Is `message` fine?
        policy:
          fine:
            threshold: 0.5
    YAML
    system bin/"jud", "check", testpath/"ok.jud"
    # Without a key or a network, a run says what is missing and exits 2.
    output = pipe_output("#{bin}/jud #{testpath}/ok.jud 2>&1", "{}", 2)
    assert_match "no API key", output
  end
end
