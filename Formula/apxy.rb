class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.2.1"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.1/apxy-1.2.1-darwin-arm64.tar.gz"
      sha256 "185e232d8c07c0fde3a080d792cc1198f37c38dbeda09f6df52b122aa6c5be4f"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.1/apxy-1.2.1-darwin-amd64.tar.gz"
      sha256 "42368a0e38493d572b2ea38742c75ee3fb7ab4353058f6d95c4d4f845a00f196"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.1/apxy-1.2.1-linux-arm64.tar.gz"
      sha256 "1c48d598c876a9c67b00fbae0b6913237d7122a53902b5caa3425279f61b31e5"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.1/apxy-1.2.1-linux-amd64.tar.gz"
      sha256 "accf7df353207f3835d7c1aef3d6af968ae1a17e76389ef537759636cf528ec9"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
