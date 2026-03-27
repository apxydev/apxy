class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.0.5"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.5/apxy-1.0.5-darwin-arm64.tar.gz"
      sha256 "adeecbceb97302ca02732e861d15c9dd9c7c89287c06c8a3464211cd38d8c6b0"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.5/apxy-1.0.5-darwin-amd64.tar.gz"
      sha256 "3c6d7e5dfb932b5def7cf6032aa00056ca259ba2cbf74a60e41bbd2e6836789e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.5/apxy-1.0.5-linux-arm64.tar.gz"
      sha256 "b10dc582c6dcb7f1359fd85baa3fedd6cf2d4992009238826b95d37db75dea40"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.5/apxy-1.0.5-linux-amd64.tar.gz"
      sha256 "22e6d51779c37c525a3c06a42fe6d5f2c96c29c940381a1b1c66a38d00634c34"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
