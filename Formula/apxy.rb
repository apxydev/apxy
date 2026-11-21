class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.5.0"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.5.0/apxy-1.5.0-darwin-arm64.tar.gz"
      sha256 "17a5728fea533aaf4f85385fbc76af016989167c69ad4ceb0dfb2efe89fb91f3"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.5.0/apxy-1.5.0-darwin-amd64.tar.gz"
      sha256 "c85aa767d0ae92928ed0714e06f0557c3a3b4a74a0c156c032e9ec19a9a4cf8b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.5.0/apxy-1.5.0-linux-arm64.tar.gz"
      sha256 "2fc044976563ea24992290ba341748a0df58780b62771e16fcee904ff8c423c0"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.5.0/apxy-1.5.0-linux-amd64.tar.gz"
      sha256 "9adbd6f1ee3cd73b17d2da91ed69961814e6192f7837c8522bf0d6d0941c1540"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
