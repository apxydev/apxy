class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.0.4"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.4/apxy-1.0.4-darwin-arm64.tar.gz"
      sha256 "f938a36a66c6cbf4760e0e3a14962f4244e839af723134fab8d5060474397cba"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.4/apxy-1.0.4-darwin-amd64.tar.gz"
      sha256 "6f9657bfc8093bdc1ecbcc3ac48f98b31ac5c6f8f8224383f6b07027342abbfd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.4/apxy-1.0.4-linux-arm64.tar.gz"
      sha256 "7b9222fd8b5120a7c767d886a06c5e57a4ea403a370a8de4a8a093efff8c54b9"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.4/apxy-1.0.4-linux-amd64.tar.gz"
      sha256 "e4099b56bca122664ff7857bbd683aae62384af693e49bef1a1f6ed9c08feb12"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
