class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.9.1"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.9.1/apxy-1.9.1-darwin-arm64.tar.gz"
      sha256 "355074ea2535c5bc786b3424d56c973d956341b08d037d71f480ff1d0aad9840"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.9.1/apxy-1.9.1-darwin-amd64.tar.gz"
      sha256 "d1bd48e2a74cc63f3862cb719b3262daeab8ad9dc4685b2be41bd76814414635"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.9.1/apxy-1.9.1-linux-arm64.tar.gz"
      sha256 "b4334fd57761b9bd3a1fcb8e7123f725df3f17d99541270e6cd8844c581944ba"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.9.1/apxy-1.9.1-linux-amd64.tar.gz"
      sha256 "458156f8545c20b5e7279f2f9e620ae7e8d3b3f86d3e90aa682d8120b32831b8"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
