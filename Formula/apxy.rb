class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.1.2"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.2/apxy-1.1.2-darwin-arm64.tar.gz"
      sha256 "b8905b86d99f42bada9d784a809784139fa32b76faeb53c12f30c7c43a451d5b"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.2/apxy-1.1.2-darwin-amd64.tar.gz"
      sha256 "4951f47705386bc7fe94782fe9963e04a2e33f1c0f8be17372211b288233facf"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.2/apxy-1.1.2-linux-arm64.tar.gz"
      sha256 "d05e04cedea92e5710c74c5aad3f73b16535e831f0fdefb3ab50e8aaeb409862"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.2/apxy-1.1.2-linux-amd64.tar.gz"
      sha256 "00cc6f6b09c62b4c601e9be24a465ce70b61387e88f3d980ad08c38e4d8f0dd2"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
