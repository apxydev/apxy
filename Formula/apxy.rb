class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.2.5"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.5/apxy-1.2.5-darwin-arm64.tar.gz"
      sha256 "2d44f906ffc1b693fb5ce11e153f05016bb1c91ed672d157c4c589f2cfa84df7"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.5/apxy-1.2.5-darwin-amd64.tar.gz"
      sha256 "5400f2301a12b22c22854c142204350c466e615ccbdaaef0e65ed9543e8f23f7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.5/apxy-1.2.5-linux-arm64.tar.gz"
      sha256 "4755332d236661fded3c91aa8a02f37fa56e0d5186509ec235a4c28cfac3ce74"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.5/apxy-1.2.5-linux-amd64.tar.gz"
      sha256 "943f085b40f366fad039e175214935d7ff9a8956ddb9ee399cba207877750802"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
