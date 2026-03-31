class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.0.9"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.9/apxy-1.0.9-darwin-arm64.tar.gz"
      sha256 "54313b6ba8f5adeb810af5354ed9cb4686d78708be267e41a64bc0f884320fe2"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.9/apxy-1.0.9-darwin-amd64.tar.gz"
      sha256 "de109270bafba1b986748408ffb6b43e70031680badbe9a95cd6decac040a485"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.9/apxy-1.0.9-linux-arm64.tar.gz"
      sha256 "2ff31fc01884675a8e917a5913b7a99d25610699fc4fd1edc47835483f93bb22"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.9/apxy-1.0.9-linux-amd64.tar.gz"
      sha256 "5084cbb127dec4c7dca6c378f9dd718a1f9f3d3301a3e300e4bbf04dadad6651"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
