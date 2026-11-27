class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.11.0"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.11.0/apxy-1.11.0-darwin-arm64.tar.gz"
      sha256 "70738e7941b3eeca7d9c5c0011804ca87b9ac916b73720f3ef2d678a13eb2c05"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.11.0/apxy-1.11.0-darwin-amd64.tar.gz"
      sha256 "111553bbbb04a585a6ff80702cb7cb2035f4a76f06a6b0f9bb00cb81ebbba9c1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.11.0/apxy-1.11.0-linux-arm64.tar.gz"
      sha256 "bd834801cd433d842aff0206a9504312a0fe535c7efd98331343ed8b2737be7b"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.11.0/apxy-1.11.0-linux-amd64.tar.gz"
      sha256 "fe8676838224ed2518b5042b05a49ef183f161a2b5b67ed6a5c00180a4a86ae8"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
