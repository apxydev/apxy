class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.8.1"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.8.1/apxy-1.8.1-darwin-arm64.tar.gz"
      sha256 "83a8286c552c504ba19405d7df3a7151e0ba4fc6fde62d7d4a6a1afa73f0e348"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.8.1/apxy-1.8.1-darwin-amd64.tar.gz"
      sha256 "368e33a25f65710ba7f55292ab6e4840e8db93f45959c1f0edf6955db98f0506"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.8.1/apxy-1.8.1-linux-arm64.tar.gz"
      sha256 "d0cfa5a088651bd0e8ebcf8010d6e45bb5eb927cc04fdf82893c74d9985bf8eb"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.8.1/apxy-1.8.1-linux-amd64.tar.gz"
      sha256 "454905f8934030ada9d8dc9a9057beb55cbd986dd283ee2126a432eefcdbef76"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
