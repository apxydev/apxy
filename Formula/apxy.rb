class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.7.0"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.7.0/apxy-1.7.0-darwin-arm64.tar.gz"
      sha256 "a7678cf9ff40c70a6797ee8cdafafcd3f2078870dc1fa545440fab0531531396"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.7.0/apxy-1.7.0-darwin-amd64.tar.gz"
      sha256 "948d7634c553907e55e89266592b2f15ec24d4b79275dad3d4f9278ed053a75d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.7.0/apxy-1.7.0-linux-arm64.tar.gz"
      sha256 "e95d378b35af21886e002b46d2a8e0882b0596491d52244b1630ed609650ece5"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.7.0/apxy-1.7.0-linux-amd64.tar.gz"
      sha256 "8c456813dba0c34fd5af4a3e774278f16da595a7dff66e3bca1f958e1a838cb7"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
