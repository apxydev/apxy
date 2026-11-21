class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.4.0"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.4.0/apxy-1.4.0-darwin-arm64.tar.gz"
      sha256 "8fdc29899383c2787361dd049ceeb455ff962ce139cc3792001139214f9f0cdd"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.4.0/apxy-1.4.0-darwin-amd64.tar.gz"
      sha256 "8e3e2b80cb66097100ca6a2bdc9a27c763c30ae35cd1267aae330a1324ae037e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.4.0/apxy-1.4.0-linux-arm64.tar.gz"
      sha256 "14b92dd4876f49b12024358b467a63e1c2224d9786eeeb530d725237002a1ad6"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.4.0/apxy-1.4.0-linux-amd64.tar.gz"
      sha256 "46bc961449963afed9f1d41396724925b2f4a091e2a7cc117c0b5b2fc76d7578"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
