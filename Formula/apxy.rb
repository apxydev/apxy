class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.1.7"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.7/apxy-1.1.7-darwin-arm64.tar.gz"
      sha256 "666087d1a24d8efda8a604a8f550cfc8ee69525109a7d8e1cd48d443da45a15d"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.7/apxy-1.1.7-darwin-amd64.tar.gz"
      sha256 "f70ee44e347cc50504cc4991c453e5a157ed8a39a42175060abda48df8b6d9a4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.1.7/apxy-1.1.7-linux-arm64.tar.gz"
      sha256 "0dbd3af7475678c163b35fc4e31669f16d51b14e9397d6d06a1b536819a64f88"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.1.7/apxy-1.1.7-linux-amd64.tar.gz"
      sha256 "dc9c2651f968e5dcc461e1e07fd01fc5b8cbc1e5565f66dfb56f32d46a3a192e"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
