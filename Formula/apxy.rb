class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.3.0"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.3.0/apxy-1.3.0-darwin-arm64.tar.gz"
      sha256 "84f03900721a7c35770cc39b4f11a1988a560bff4d0af86d44297db18d08b88b"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.3.0/apxy-1.3.0-darwin-amd64.tar.gz"
      sha256 "e6d70ec05aee140d50c92f461b5afd3f75efd7c42d774a425d97070296a2d04f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.3.0/apxy-1.3.0-linux-arm64.tar.gz"
      sha256 "e9cf3d718173c950030bdf172f96301bce6835399d9fdd073207331b5843cab5"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.3.0/apxy-1.3.0-linux-amd64.tar.gz"
      sha256 "cdbc034a3307b6717574c6a9d204a8179a5f0ef28a886e277176b50edfdc77ed"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
