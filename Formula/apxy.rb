class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.0.7"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.7/apxy-1.0.7-darwin-arm64.tar.gz"
      sha256 "6c04ee92fb1b6f755a2f582520da9c64a283d249831624ad2a753405b55819ce"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.7/apxy-1.0.7-darwin-amd64.tar.gz"
      sha256 "34639c2bec66da19a55d1d611b8926dc4225d53e7effbbcd5ba862b651fe2b7f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.7/apxy-1.0.7-linux-arm64.tar.gz"
      sha256 "1c34d2bf8f610ce754787a64ff532b3d9a2529ae5b771bfda3d22dfa686d834f"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.7/apxy-1.0.7-linux-amd64.tar.gz"
      sha256 "463285e425e75ccc33a0e8c2dc3204b92e64a38566daa3815fdf7fd92e0a7f84"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
