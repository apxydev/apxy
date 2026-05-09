class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.2.2"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.2/apxy-1.2.2-darwin-arm64.tar.gz"
      sha256 "54e3623f5df7ef336418a083d819f5993d5965f39290593e06085183ecaf3a83"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.2/apxy-1.2.2-darwin-amd64.tar.gz"
      sha256 "d64ae8e8110c93e8ecf9d1f37ae08445af0de26d50e4e25e58b3373b1230079f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.2.2/apxy-1.2.2-linux-arm64.tar.gz"
      sha256 "e6f1a6c3f6ae017325ab6faebc2a30f62acacd23786e547968813a5af0fd4999"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.2.2/apxy-1.2.2-linux-amd64.tar.gz"
      sha256 "14c8bf33b26b3a77dca965fdfb707dbde34ef2dab3029ef5e4e89387e96c4b10"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
