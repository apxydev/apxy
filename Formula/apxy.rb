class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.1.1"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.1/apxy-1.1.1-darwin-arm64.tar.gz"
      sha256 "2ca6769a798508fcf15c4d8e87e159be6578e781772dc9021a949ec0da4c2ab3"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.1/apxy-1.1.1-darwin-amd64.tar.gz"
      sha256 "7853e647817c09b500830d008a082e61de9f65ad89300184a7175557adb2adb3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.1/apxy-1.1.1-linux-arm64.tar.gz"
      sha256 "c987f1b172d66529bab1d7edcbcc5311b5435e425588054a80c15225567767d8"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.1/apxy-1.1.1-linux-amd64.tar.gz"
      sha256 "113e25264a6314945d076521e66db3f9e6592fb83851b13dc4f5f7b44b7dcf47"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
