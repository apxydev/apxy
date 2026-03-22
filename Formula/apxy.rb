class Apxy < Formula
  desc "Desktop network proxy for HTTPS debugging — inspect, mock, debug"
  homepage "https://github.com/apxydev/apxy"
  version "1.0.3"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.3/apxy-1.0.3-darwin-arm64.tar.gz"
      sha256 "d8efa932f8f90ef26de0643ca07ca157de237ab6ae267e7ebde216f6a201f2be"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.3/apxy-1.0.3-darwin-amd64.tar.gz"
      sha256 "8a7adeb34c8a1b18426846bdc2fc4e7e25da20ec6e0efd6598488a5fe8b3d625"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/apxydev/apxy/releases/download/v1.0.3/apxy-1.0.3-linux-arm64.tar.gz"
      sha256 "20e80adfaf2da8755276d0a7bebe8ddd03451599cb7d2f853cd2d8dc3f3a13f4"
    else
      url "https://github.com/apxydev/apxy/releases/download/v1.0.3/apxy-1.0.3-linux-amd64.tar.gz"
      sha256 "d58df7e87122edaac7c767f9a57ba1f793de57142fb801b7d27c6e8561b5e6c2"
    end
  end

  def install
    bin.install "apxy"
  end

  test do
    system bin/"apxy", "--version"
  end
end
