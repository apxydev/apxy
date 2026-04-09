class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.1.4"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.4/apxy-1.1.4-darwin-arm64.tar.gz"
      sha256 "3d6f6a66ed9eb79b0add398b083f3ca92fb2503cb4266f0aba5e9494b2b574b5"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.4/apxy-1.1.4-darwin-amd64.tar.gz"
      sha256 "ef63ee44efbb1930bb7f0dc37b0e578e631629daaac312bf6f591e92aaee9e1c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.4/apxy-1.1.4-linux-arm64.tar.gz"
      sha256 "59ba709e173e32bddd9d11fe5d37b75cd856dc0657966ad94ced0e42e7076fe1"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.4/apxy-1.1.4-linux-amd64.tar.gz"
      sha256 "2de3d4f0ecfb27c22258930a810392a0861e72164078b03c12dc939981bc0feb"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
