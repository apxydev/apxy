class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.0.8"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.8/apxy-1.0.8-darwin-arm64.tar.gz"
      sha256 "89081b1efb0ade994c32eed7dc04130043df18ef4eb578db28a4b0bb01082048"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.8/apxy-1.0.8-darwin-amd64.tar.gz"
      sha256 "75a624320b649c73806acdd152542ad3b72f23a69ef032dd7e81ef7211014bca"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.8/apxy-1.0.8-linux-arm64.tar.gz"
      sha256 "e0336916d26caca7b3449352ed1d6ac85358f4992d6b34d55983f7f78be3e6f7"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.8/apxy-1.0.8-linux-amd64.tar.gz"
      sha256 "925599ee2bb7c07e0b1603c408ca6bdb0991be732d8ca541ffafde568be25dbf"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
