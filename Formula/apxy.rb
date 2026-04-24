class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.2.0"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.0/apxy-1.2.0-darwin-arm64.tar.gz"
      sha256 "9a48c88b406b498cda230ba421359d2444ef1df797f2a8f102ddded9e6bff9ee"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.0/apxy-1.2.0-darwin-amd64.tar.gz"
      sha256 "56984cc4805979376f51644c47b34d3ec9fe5c4ad7df4900f64fe9a22297efe8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.0/apxy-1.2.0-linux-arm64.tar.gz"
      sha256 "79f9039b5fa4f737cf1ce69d8f4433c49bfa941d6d0e45653a0afd0d800d34e8"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.0/apxy-1.2.0-linux-amd64.tar.gz"
      sha256 "1029c08d53f2f3a20f7418dc1cf07fb9d47d3befc1bcaef8e722e2119dabc161"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
