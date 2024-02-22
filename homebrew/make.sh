#!/bin/bash

repo_path=$(git rev-parse --show-toplevel)
version=$(sed -n '/^SVER_VERSION=/s/.*=//p' "${repo_path}/sver")
sha256sum=$(shasum -a 256 "${repo_path}/sver" | cut -f1 -d\ )

cat <<_EOF_ >"${repo_path}/homebrew/sver.rb" 
class Sver < Formula
  desc "Semver (Semantic Version) parsing & utility script/function library in pure bash"
  homepage "https://github.com/robzr/sver"
  url "https://github.com/robzr/sver/releases/download/${version}/sver"
  sha256 "${sha256sum}"
  license "CC-BY-SA-3.0"

  def install
    bin.install "sver"
  end

  test do
    assert_match "${version}", shell_output("#{bin}/sver version")
  end
end
_EOF_
