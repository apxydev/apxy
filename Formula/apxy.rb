class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.1.0"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.0/apxy-1.1.0-darwin-arm64.tar.gz"
      sha256 "030c6cfb9fbeb7794ef97208fae56c0e3d473e8e5a7fe161546170c4fc5f48b9"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.0/apxy-1.1.0-darwin-amd64.tar.gz"
      sha256 "f995bb8e22cd69eaaf032e4f0100959ed5a7394192d4820a1c1e56155c5a492c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.0/apxy-1.1.0-linux-arm64.tar.gz"
      sha256 "8fe58af660e672dfc51394daa915ab7b0ad10427b28da8f7808bb5268c19b15c"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.0/apxy-1.1.0-linux-amd64.tar.gz"
      sha256 "518108e0c51681065c73ee09a11352b3aa3e698978c3cd724ea6115cbc69343c"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
