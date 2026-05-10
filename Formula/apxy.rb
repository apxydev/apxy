class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.2.2"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.2/apxy-1.2.2-darwin-arm64.tar.gz"
      sha256 "970fb8c3ea0d384be84d974dc62ef60c86aafbb135e2236cb1ccf7ce8f770492"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.2/apxy-1.2.2-darwin-amd64.tar.gz"
      sha256 "53833aac234fb3ddec50ae777d3d081028b4bf2f648aedd3059d162da88b180d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.2/apxy-1.2.2-linux-arm64.tar.gz"
      sha256 "c0a73e6e138d40da0300e7f0153e8ddde4f1e012632d0345a72bba27e22ff3b2"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.2/apxy-1.2.2-linux-amd64.tar.gz"
      sha256 "c39c67028c3ea29c6bd2d7c64f8dbe71f30e17a0f8923684e31ab80f0db1ad50"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
