class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.6.1"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.6.1/apxy-1.6.1-darwin-arm64.tar.gz"
      sha256 "99ea47a5ba4bcd7f07a93f76e280f0bdcbc383af6231ecb42eaf70ce05231113"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.6.1/apxy-1.6.1-darwin-amd64.tar.gz"
      sha256 "8713c4ec8341be5fab08fd2f60292e2b5ae71cb5dfe71514dbf876a7c9381fd2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.6.1/apxy-1.6.1-linux-arm64.tar.gz"
      sha256 "cabec58318d6c84d6536d51f80567b3e72200b9f613821be1e7bb9a2f84fa03e"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.6.1/apxy-1.6.1-linux-amd64.tar.gz"
      sha256 "a5df0c4fb8f2e3ade78e5df2b04ed5f01c25b9132ce8201af59924e4fe71b8f9"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
