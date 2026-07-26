# Archives

Creates and extracts common archive formats on macOS and Debian/Ubuntu Linux.

| Utility | Purpose |
| --- | --- |
| [Zip](https://infozip.sourceforge.net/Zip.html) | Creates ZIP archives from files and directories. |
| [UnZip](https://infozip.sourceforge.net/UnZip.html) | Extracts files from ZIP archives. |
| [Zstandard](https://facebook.github.io/zstd/) | Compresses and decompresses data with the Zstandard algorithm. |
| [Ouch](https://github.com/ouch-org/ouch) | Creates, extracts, and lists many archive formats through a unified command-line interface. |
| [bzip2](https://sourceware.org/bzip2/) | Compresses and decompresses data with the bzip2 algorithm. |
| [7-Zip](https://www.7-zip.org/) | Creates and extracts 7z and many other archive formats. |
| [GNU Tar](https://www.gnu.org/software/tar/) | Creates and extracts tar archives and their compressed variants. |
| [RAR](https://www.rarlab.com/) | Creates proprietary RAR archives for compression and backup workflows. |
| [UnRAR](https://www.rarlab.com/rar_add.htm) | Extracts and tests proprietary RAR archives. |

The `bzip2` package provides the `bzip2` command; there is no separate standard `bzip` command. macOS already includes Zip, UnZip, and Tar, so Homebrew adds enhanced alternatives where applicable. On Linux, the setup script uses a configured APT package for Ouch when available or the project's official static release otherwise.

RAR and UnRAR are proprietary utilities: the Linux setup uses them only when the configured APT sources provide the packages, which may require enabling a non-free or multiverse repository.
