class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.6.2"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.6.2/apxy-1.6.2-darwin-arm64.tar.gz"
      sha256 "95626a185b65d3ddd3b972a88ac0a1b1dd85fe21fb9a1b1a4ffba3729da49626"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.6.2/apxy-1.6.2-darwin-amd64.tar.gz"
      sha256 "68de994570a9bb119e916e5924465042c5d2b008346b61a701277cfcbd4891df"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.6.2/apxy-1.6.2-linux-arm64.tar.gz"
      sha256 "097d91de08e60a1ed8360a2da282c975450da22b44826a3a883f9c0e1b6a0dd9"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.6.2/apxy-1.6.2-linux-amd64.tar.gz"
      sha256 "3ea34cf350fd7d4d1b03f53a099432e0de4cfb7de66c73bdf1e8faa8e0f48fb3"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
