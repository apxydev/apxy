class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.1.5"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.5/apxy-1.1.5-darwin-arm64.tar.gz"
      sha256 "1996296009262b7c5e94afd58cd9c49c84dfbfb66eb22bf116b46268ab715eb6"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.5/apxy-1.1.5-darwin-amd64.tar.gz"
      sha256 "200497c2e4830c9219661d1898cf34ca47a092b7f59d077e214f621396647572"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.5/apxy-1.1.5-linux-arm64.tar.gz"
      sha256 "206da225b351236460bf1056694cabe1dc9d76871afdbca0fe0f11e9e75687de"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.5/apxy-1.1.5-linux-amd64.tar.gz"
      sha256 "308236ae9334e0e81fdb56ae81748cfdb634eaf7a1584ce6c2c296985de7474c"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
