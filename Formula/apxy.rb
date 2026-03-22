class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.0.2"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.2/apxy-1.0.2-darwin-arm64.tar.gz"
      sha256 "9cc360b647ec2df7274dc696792a365303fed7064cf0376d8040bda33a3da31a"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.2/apxy-1.0.2-darwin-amd64.tar.gz"
      sha256 "d0c8565efb099e8d9fe168748232439543518bcfbf3706d515c06ef0a0070d37"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.2/apxy-1.0.2-linux-arm64.tar.gz"
      sha256 "d7a0e9c7d1673a11a6b0286065ccb45764577cc9419f4f9a12bbdb33bce4d5a1"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.2/apxy-1.0.2-linux-amd64.tar.gz"
      sha256 "bd06aad78b28d4eb51d6343d3623306be8ed17718b1b1108cdf4d3d3ce84c664"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
