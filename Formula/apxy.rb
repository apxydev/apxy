class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.2.6"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.6/apxy-1.2.6-darwin-arm64.tar.gz"
      sha256 "71c1074e236ced3dfb8bf7ad7f29e1fee52caf3308357d0845d0fe8d4410e087"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.6/apxy-1.2.6-darwin-amd64.tar.gz"
      sha256 "eaebbfeb59a34030b87fd5dbb5b363e8cd26055d21fd276ba30a179a591cf2ba"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.6/apxy-1.2.6-linux-arm64.tar.gz"
      sha256 "2b4529c1822490992e28f74117bfd2bd82cf78df3f2bd8d6978a6d63e77c7ced"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.6/apxy-1.2.6-linux-amd64.tar.gz"
      sha256 "33cd8a951e37b8797634239102f4d4f6b8f1efb4111d6613fa4215f795925961"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
