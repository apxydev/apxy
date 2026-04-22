class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.1.8"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.8/apxy-1.1.8-darwin-arm64.tar.gz"
      sha256 "61be4ae0a4ac98fdefc1a3ec942c8fcd028cb7e58b6a578070b94f97c2225abf"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.8/apxy-1.1.8-darwin-amd64.tar.gz"
      sha256 "13e18c4c00db2e19f89469690dbd7275cc370126f21aeeb5e7bbb1a8f5f6af7c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.8/apxy-1.1.8-linux-arm64.tar.gz"
      sha256 "f8343542985978fe51089884fc2605e9535747a198b4e22fcfbafb92f9ce6402"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.8/apxy-1.1.8-linux-amd64.tar.gz"
      sha256 "22b4cc76e9dbf95889ea9ab4147840884f944e0d41d9badbb30b7bd15c5a497e"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
