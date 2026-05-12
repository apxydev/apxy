class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.2.3"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.3/apxy-1.2.3-darwin-arm64.tar.gz"
      sha256 "5a6949e7e0747eca5ee5d7de62ca9ad988b35ff85d97ab3f3af2a50048841b41"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.3/apxy-1.2.3-darwin-amd64.tar.gz"
      sha256 "2d06829a14db37006e982e29fc12eeadfbc65eaa1ec0ecb4772ebe19b625b892"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.3/apxy-1.2.3-linux-arm64.tar.gz"
      sha256 "d701ff0f2de7227c358faeedecc43145792da27c30e3b58dbf5bfe24267bcc5f"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.3/apxy-1.2.3-linux-amd64.tar.gz"
      sha256 "9d76d3b6c0e69c918a1275f4b5a22268a6eeca683ec97ac0ae67a405efe48996"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
