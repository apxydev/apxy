class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.9.0"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.9.0/apxy-1.9.0-darwin-arm64.tar.gz"
      sha256 "d0afc37e68246ead463a5d465c6c9ad7b3e8bb1f799bec94478654ff8aeb66cd"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.9.0/apxy-1.9.0-darwin-amd64.tar.gz"
      sha256 "b749772cffa4cc22931a8eb5bc084a5af3cbe81e075e12c08796e0b55783cb10"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.9.0/apxy-1.9.0-linux-arm64.tar.gz"
      sha256 "13509c67aca834ab7217ba7c3a3c08f6b33501d048fa3a20c2c313cce58239fd"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.9.0/apxy-1.9.0-linux-amd64.tar.gz"
      sha256 "9a188e7f8e7c2fa4d24e553ad62c26240e6dcf2545ef7e1bf47602e1a14522f6"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
