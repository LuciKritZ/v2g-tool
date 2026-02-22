# v2g-tool

A lightweight CLI tool that converts video files to high-quality, optimized GIFs. Uses **ffmpeg** for encoding and **gifsicle** for compression, with simple quality presets so you can trade size for fidelity.

## Features

- **Quality presets** — Choose from 5 presets (100, 80, 50, 25, 10) instead of tuning fps/scale/lossy by hand
- **Optimized pipeline** — Generates a single palette and applies it for consistent colors; optional gifsicle lossy compression
- **Cross-platform** — Works on macOS (Homebrew), Arch Linux, and Debian/Ubuntu (Fedora: install deps manually)
- **Single command** — `v2g video.mp4` or `v2g video.mp4 output.gif -q 80`

## Requirements

- **ffmpeg** — video decoding and GIF encoding
- **gifsicle** — GIF optimization and optional lossy compression

The install script can install these for you on supported systems.

## Installation

### One-line install (recommended)

**From the project root** (script still downloads library and executable from GitHub):

```bash
./install.sh
```

**From anywhere** (downloads the install script from GitHub, then the library and executable):

```bash
curl -fsSL https://raw.githubusercontent.com/LuciKritZ/v2g-tool/main/install.sh | sudo bash
```

The script will:

1. Detect your OS and install **ffmpeg** and **gifsicle** (Homebrew on macOS, pacman on Arch, apt on Debian/Ubuntu)
2. Download the latest `v2g.sh` and `v2g` from the `main` branch on GitHub and install them to `/usr/local/lib/v2g/` and `/usr/local/bin/`

You may need to run with `sudo` when the script prompts for it (e.g. when creating `/usr/local/lib/v2g` or installing files).

### macOS (Homebrew)

On macOS you can install via the Homebrew formula in this repo. It pulls in **ffmpeg** and **gifsicle** as dependencies and installs the script to Homebrew’s prefix:

```bash
brew tap LuciKritZ/v2g-tool
brew install v2g
```

Or in one command:

```bash
brew install LuciKritZ/v2g-tool/v2g
```

### Arch Linux (AUR)

If you're on Arch and prefer to install from the [AUR](https://aur.archlinux.org/packages/v2g), use an AUR helper or clone and build manually:

```bash
# With an AUR helper (e.g. yay, paru)
yay -S v2g
# or
paru -S v2g

# Or clone and build manually
git clone https://aur.archlinux.org/v2g.git
cd v2g
makepkg -si
```

The AUR package pulls in **ffmpeg** and **gifsicle** as dependencies.

### Manual install

1. Install **ffmpeg** and **gifsicle** using your package manager.
2. Copy files:

   ```bash
   sudo mkdir -p /usr/local/lib/v2g
   sudo cp lib/v2g.sh /usr/local/lib/v2g/
   sudo cp bin/v2g /usr/local/bin/
   sudo chmod +x /usr/local/bin/v2g
   ```

Ensure `/usr/local/bin` is in your `PATH`.

## Usage

```text
v2g <input_video> [output_gif] [options]
```

### Options

| Option        | Description                                      |
|---------------|--------------------------------------------------|
| `-h`, `--help` | Show help and exit                               |
| `-q`, `--quality` | Quality preset: `100`, `80`, `50`, `25`, or `10` (default: `50`) |

### Quality presets

| Preset | Name           | FPS | Resolution   | Compression   |
|--------|----------------|-----|--------------|----------------|
| **100** | Pixel Perfect | 20  | Original     | None           |
| **80**  | High          | 15  | Max 1080p    | Light          |
| **50**  | Medium *(default)* | 12 | Max 720p     | Standard       |
| **25**  | Low           | 10  | Max 480p     | High           |
| **10**  | Potato        | 5   | Max 320p     | Aggressive     |

Higher preset = better quality and larger file size.

### Examples

```bash
# Default (medium quality, output: video.gif)
v2g demo.mp4

# Custom output name
v2g demo.mp4 my-clip.gif

# High quality, larger file
v2g demo.mp4 -q 100

# Small thumbnail-style GIF
v2g demo.mp4 icon.gif -q 10

# Help
v2g --help
```

## Supported platforms

| OS              | Package manager | Notes                    |
|-----------------|-----------------|--------------------------|
| macOS           | Homebrew        | `brew install ffmpeg gifsicle` or `brew install LuciKritZ/v2g-tool/v2g` (formula in repo) |
| Arch Linux      | Pacman          | `pacman -S ffmpeg gifsicle`    |
| Arch Linux      | AUR             | [v2g](https://aur.archlinux.org/packages/v2g) — `yay -S v2g` or `paru -S v2g` |
| Debian / Ubuntu | Apt             | `apt install ffmpeg gifsicle`  |
| Fedora          | DNF             | Not auto-detected by installer; install deps manually, then use manual install below. |

On other systems, install **ffmpeg** and **gifsicle** manually and use the manual install steps below.

## How it works

1. **ffmpeg** decodes the video, applies fps + scaling (Lanczos), generates a palette from the stream, then encodes to GIF using that palette.
2. The GIF is piped to **gifsicle** for `-O3` optimization and, for presets &lt; 100, `--lossy=N` to reduce file size.

The script uses a single palette for the whole clip, so colors stay consistent and the result is suitable for short clips (demos, UI recordings, memes).

## Inspiration

This tool was inspired by [Convert .mov or .MP4 to .gif](https://gist.github.com/SheldonWangRJT/8d3f44a35c8d1386a396b9b49b43c385), a gist by [SheldonWangRJT](https://github.com/SheldonWangRJT) that shows how to convert video to GIF in one command using **ffmpeg** and **gifsicle**. That approach—no GUI, just Homebrew and the terminal—is what led to building v2g-tool with quality presets, cross-platform install, and a reusable `v2g` CLI. Thanks to Sheldon and everyone who contributed ideas in the gist’s comments.

## License

See [LICENSE](LICENSE) in this repository.
