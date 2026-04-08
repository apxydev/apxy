class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.1.3"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.3/apxy-1.1.3-darwin-arm64.tar.gz"
      sha256 "855a65238b41d1794e119e2716be265a1c65e7e4c2cac2e9ff23a179d5201642"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.3/apxy-1.1.3-darwin-amd64.tar.gz"
      sha256 "80267c9d4ad6440f0107d11c5c3364e1466bcafd8a4f6b116314926a1571e7a3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.3/apxy-1.1.3-linux-arm64.tar.gz"
      sha256 "751b997c45572fa2f7d3daa826a639a734fa0937f1601b07bacea6befa7e9449"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.3/apxy-1.1.3-linux-amd64.tar.gz"
      sha256 "c9a734067bce3ba7cba214bcf7681ce08fe4dc222885ba98e59e8bccba182fc6"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
