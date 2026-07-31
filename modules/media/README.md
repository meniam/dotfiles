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
| [MediaInfo](https://mediaarea.net/en/MediaInfo) | Reports technical and tag metadata for media files. |
| [ExifTool](https://exiftool.org/) | Reads and writes metadata in images, audio, video, and documents. |
| [Poppler](https://poppler.freedesktop.org/) | Supplies PDF rendering and extraction tools such as `pdftoppm`. |
| [Chafa](https://hpjansson.org/chafa/) | Renders image previews as terminal graphics or text. |

The Homebrew and APT manifests install equivalent toolsets under
platform-specific package names, such as `media-info` versus `mediainfo` and
`poppler` versus `poppler-utils`.

This module has no Stow payload or setup script. Its probe checks the primary
command from each package and accepts either ImageMagick's modern `magick`
entry point or the legacy `convert` command.

The `fs` module depends on `media` because Yazi uses these commands for image,
audio, video, metadata, and PDF previews.
