class Sver < Formula
  desc "Semver (Semantic Version) parsing & utility script and function library in pure bash"
  homepage "https://github.com/robzr/sver"
  url "https://github.com/robzr/sver/releases/download/v1.0.0/sver"
  sha256 "1f1c3b26e980f8b89d2c13030a63074b6af6784c067cd0e7f612d247d2384fa5"
  license "CC-BY-SA-3.0"

  def install
    bin.install "sver"
  end

  test do
    assert_match "v1.0.0", shell_output("#{bin}/sver version")
  end
end
