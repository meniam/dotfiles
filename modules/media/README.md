# Media

Command-line tools for inspecting, converting, rendering, and previewing media
and document formats.

- Platforms: macOS and Linux
- Default: off
- Dependencies: none

## Included tools

| Utility | Purpose |
| --- | --- |
| [FFmpeg](https://ffmpeg.org/) | Probes, records, converts, and streams audio and video. |
| [ImageMagick](https://imagemagick.org/) | Converts and manipulates raster images. |
| [Ghostscript](https://www.ghostscript.com/) | Renders PostScript and PDF, and backs ImageMagick's PDF and EPS support. |
| [librsvg](https://gitlab.gnome.org/GNOME/librsvg) | Renders SVG through `rsvg-convert`, and backs ImageMagick's SVG support. |
| [MediaInfo](https://mediaarea.net/en/MediaInfo) | Reports technical and tag metadata for media files. |
| [ExifTool](https://exiftool.org/) | Reads and writes metadata in images, audio, video, and documents. |
| [Poppler](https://poppler.freedesktop.org/) | Supplies PDF rendering and extraction tools such as `pdftoppm`. |
| [qpdf](https://qpdf.sourceforge.io/) | Splits, merges, and repairs PDF files without re-rendering them. |
| [Pandoc](https://pandoc.org/) | Converts between document markup formats. |
| [Chafa](https://hpjansson.org/chafa/) | Renders image previews as terminal graphics or text. |
| [libheif](https://github.com/strukturag/libheif) | Converts HEIC and AVIF through `heif-convert`. |
| [WebP](https://developers.google.com/speed/webp) | Encodes and decodes WebP through `cwebp` and `dwebp`. |
| [Tesseract](https://github.com/tesseract-ocr/tesseract) | Extracts text from images and scans. |
| [SoX](https://sourceforge.net/projects/sox/) | Edits, converts, and analyses audio files. |
| [yt-dlp](https://github.com/yt-dlp/yt-dlp) | Downloads video and audio from streaming sites. |
| [LibreOffice](https://www.libreoffice.org/) | Converts office documents; installed as a macOS cask only. |

The Homebrew and APT manifests install equivalent toolsets under
platform-specific package names, such as `media-info` versus `mediainfo`,
`poppler` versus `poppler-utils`, and `librsvg` versus `librsvg2-bin`.

## Delegates and previewers

ImageMagick does not link Ghostscript or librsvg in — it runs them as external
programs. The Homebrew build reports its built-in delegates as:

```
bzlib freetype heic jng jpeg lcms ltdl lzma png tiff webp xml zlib zstd
```

Neither `gs` nor `rsvg` appears there, so without those two packages
`magick file.pdf out.png` fails outright and SVG falls back to ImageMagick's own
renderer. ImageMagick 6 on Debian and Ubuntu also has no HEIC delegate, which is
why `heif-convert` is installed separately.

Two of Yazi's previewers are deliberately single-platform:

- `office` shells out to LibreOffice. It is declared in `casks.brew`, and casks
  are installed on macOS only, so a Linux server does not pull a desktop office
  suite in. There the previewer reports the missing command and the file falls
  through to the hex previewer.
- `preview-epub` needs `gnome-epub-thumbnailer`, which is packaged for Debian
  and Ubuntu only. EPUB covers therefore preview on Linux and not on macOS.

The module probe follows the same split: it requires `soffice` on macOS and
`gnome-epub-thumbnailer` on Linux, and accepts either ImageMagick's modern
`magick` entry point or the legacy `convert` command.

This module has no Stow payload or setup script.

The `fs` module depends on `media` because Yazi uses these commands for image,
audio, video, metadata, and PDF previews.
