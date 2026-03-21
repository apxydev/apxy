class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.1.1"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v#{version}/apxy-#{version}-darwin-arm64.tar.gz"
      sha256 "983a9520e17f2de9f8ab82938a6dc090e0f3f6c2e6d650c0a3be0c036f50b1ba"
    else
      url "https://github.com/apxydev/apxy/releases/download/v#{version}/apxy-#{version}-darwin-amd64.tar.gz"
      sha256 "7903ccf4fc0df5bc04029f816c015a5487176b31f6a31feadf9e224c5e9633e2"
    end
  end

  on_linux do
    url "https://github.com/apxydev/apxy/releases/download/v#{version}/apxy-#{version}-linux-amd64.tar.gz"
    sha256 "bbaf9e813fa7068ecca44f43433f0785e9224aa82e3563a9362a15a9824d28b2"
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
