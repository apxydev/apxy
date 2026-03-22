class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.0.1"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.0/apxy-1.0.0-darwin-arm64.tar.gz"
      sha256 "42da2e828f31b5bc7f682853d1ae4bf3d4d9587a32b804fc4761fcb1d46851f8"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.0/apxy-1.0.0-darwin-amd64.tar.gz"
      sha256 "4fd3ff31238ce57a6516a710d1bf33517112ea6783857c9d5895d12dad4f49d4"
    end
  end

  on_linux do
    url "https://github.com/apxydev/apxy/releases/download/v1.0.0/apxy-1.0.0-linux-amd64.tar.gz"
    sha256 "223e2e514a91f3f54741d530785dc2e231fee861fa0a61169f43af4e5ae002fc"
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
