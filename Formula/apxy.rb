class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.6.0"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.6.0/apxy-1.6.0-darwin-arm64.tar.gz"
      sha256 "40bd478e84574c78c04ca79cce5422964357030bb4d31abb373551f1e04d762e"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.6.0/apxy-1.6.0-darwin-amd64.tar.gz"
      sha256 "fe423c73a6be91ef7d3a478d823c077ce1cd570738bc1a336fccc667e0e2e795"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.6.0/apxy-1.6.0-linux-arm64.tar.gz"
      sha256 "77b3faabb635d930f2c0b1f40c1de92e013dcf357d7f44163dbd15caf5883b7a"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.6.0/apxy-1.6.0-linux-amd64.tar.gz"
      sha256 "bde2642ec1966f7408b76a6eb359c97ca3bdcc3549ac8c3f6f203bdf585cc7ae"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
