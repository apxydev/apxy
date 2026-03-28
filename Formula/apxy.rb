class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.0.6"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.6/apxy-1.0.6-darwin-arm64.tar.gz"
      sha256 "16b0ada4571a280725d200ed9bc765b7a30bd1587979b7d12dd4f482e6c6ab3d"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.6/apxy-1.0.6-darwin-amd64.tar.gz"
      sha256 "285985529a52635f547f962c49054d9e1c0c6554f5368903de5197d8df340922"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.6/apxy-1.0.6-linux-arm64.tar.gz"
      sha256 "541efa508ab3dd8f95fdc2f5634fa09f387c89b17398f88822dd53bd4b559443"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.6/apxy-1.0.6-linux-amd64.tar.gz"
      sha256 "7a37173d4c2223e615524ca08d7bdd46bac4d7102b8832d2a191df8f7f97e1cc"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
