class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.1.9"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.9/apxy-1.1.9-darwin-arm64.tar.gz"
      sha256 "74ae789c93c4249485413dcf6ed8be3d044d7dc557848b6bab1a02f76f8ef8bf"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.9/apxy-1.1.9-darwin-amd64.tar.gz"
      sha256 "1e7506d56bd2ca1d97f8629ccd2a2933ee25dbe2dad1b77f881ae9d8cf2d8f38"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.9/apxy-1.1.9-linux-arm64.tar.gz"
      sha256 "405f79e9f66665e54e396470c7ec559cbbb127ecd9d384953018dc54375b377d"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.9/apxy-1.1.9-linux-amd64.tar.gz"
      sha256 "1f84a5abfcd89117db5662099f87c7e23d52f0a4168d1a24ae90002974d29bb7"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
