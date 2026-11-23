class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.8.0"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.8.0/apxy-1.8.0-darwin-arm64.tar.gz"
      sha256 "e927730672f1a3776f27e30884202eec90568910f6d2e85a49ed6edb458672fa"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.8.0/apxy-1.8.0-darwin-amd64.tar.gz"
      sha256 "e4f5a70140d81a213a6f6f33d983711a6aa28431c5506c0c2ced9aec47cedeae"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.8.0/apxy-1.8.0-linux-arm64.tar.gz"
      sha256 "80d66e3dbdcee4ed29518410cc56ce752d236c9badf7cb8db7823cdf2d460fb0"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.8.0/apxy-1.8.0-linux-amd64.tar.gz"
      sha256 "24257ed98169c03d5cf9b062152ef860abd0762bcea7113b03b6f114bed57b7c"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
