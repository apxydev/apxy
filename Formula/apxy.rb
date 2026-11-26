class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.10.0"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.10.0/apxy-1.10.0-darwin-arm64.tar.gz"
      sha256 "133ae4dff1457a536af940e2bb415f1985299fa113e23b2d755388cfb3a268af"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.10.0/apxy-1.10.0-darwin-amd64.tar.gz"
      sha256 "ba2d603896aebb202056a662bab6106f49ff3c23bdf83983caf7e5239f773341"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.10.0/apxy-1.10.0-linux-arm64.tar.gz"
      sha256 "737b5f5a5a03613b20b1e064314e210b543215d46168318f05074877660def8d"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.10.0/apxy-1.10.0-linux-amd64.tar.gz"
      sha256 "fe80fb4cf228a6d8d5af7f6aab5fc11ad219f08f142f60874ad0ee63d218e9b2"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
