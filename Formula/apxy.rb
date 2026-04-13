class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.1.6"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.6/apxy-1.1.6-darwin-arm64.tar.gz"
      sha256 "00454c4fdc4a6686fa9534a19239792b8da592a42db62c370c708053d636b482"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.6/apxy-1.1.6-darwin-amd64.tar.gz"
      sha256 "5490d46e0048ef8724bbc88ec405512e17113f804e59dd6ed9b5333859fc6f8b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.6/apxy-1.1.6-linux-arm64.tar.gz"
      sha256 "e4dba867555e4ca742a60ed403f2f5e54823a4ef738c87be022f78a807c68640"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.6/apxy-1.1.6-linux-amd64.tar.gz"
      sha256 "293f9355fc86e5b1cddf3aa04fd040d5679b29210522661089de5c9bbe74487d"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
