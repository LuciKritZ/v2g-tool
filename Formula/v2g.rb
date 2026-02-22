class V2g < Formula
    desc "Video to optimized GIF converter using ffmpeg and gifsicle"
    homepage "https://github.com/LuciKritZ/v2g-tool"
    url "https://github.com/LuciKritZ/v2g-tool/archive/refs/tags/v1.0.0.tar.gz"
    sha256 "9a502570221f5f5c2e8b50790ee8c36f0e9680587715ae8305275cf0c1183f4b"
    license "MIT"

    depends_on "ffmpeg"
    depends_on "gifsicle"

    def install
        (lib/"v2g").install "lib/v2g.sh"
        bin.install "bin/v2g"

        # Patch the binary to look in the Homebrew-specific library path
        # Homebrew uses 'inreplace' which is like 'sed' but for Ruby
        inreplace bin/"v2g", "/usr/local/lib/v2g/v2g.sh", "#{lib}/v2g/v2g.sh"
    end
end
