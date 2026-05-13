class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.2.4"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.4/apxy-1.2.4-darwin-arm64.tar.gz"
      sha256 "fa4552c5565e71c23714527ba156052efa348ee0b43539ec508e7f87af5f8626"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.4/apxy-1.2.4-darwin-amd64.tar.gz"
      sha256 "059e2a5b421a91d1d31266f49863b0973a711186425fa32cf2da416d84537a19"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.4/apxy-1.2.4-linux-arm64.tar.gz"
      sha256 "1feb436af21b5deb8d76c55f100525d34c108d3b55ebc43218983ef59fd32109"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.4/apxy-1.2.4-linux-amd64.tar.gz"
      sha256 "a8d563d8a09d4e9cf6c44094ddb8132dac8aabe7659815189a2693d44c20b140"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
