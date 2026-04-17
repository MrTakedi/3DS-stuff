# 3DS Utilities: CIA Downloader & Batch Decryptor

A collection of utility scripts for the Nintendo 3DS to download CIA files from Nintendo's Content Delivery Network (CDN) and batch decrypt `.3ds` and `.cia` files. This repository includes both Windows Batch (`.bat`) and Linux/macOS Shell (`.sh`) versions of the scripts.

## Features

* **CIA Downloader:** Downloads encrypted 3DS titles directly from Nintendo's CDN (NUS/CCS) using a 16-character Title ID and fetches the required `cetk` and `tmd` files. It then automatically repackages the downloaded data into an installable `.cia` file.
* **Batch CIA & 3DS Decryptor:** Scans the current directory for encrypted `.3ds`, `.cia`, and `.ncch` files, automates the extraction and decryption process, and repackages them into decrypted `.cci` or `.cia` formats (handling both Patches and DLCs automatically).

## Prerequisites

To use these scripts, ensure the following command-line tools are installed and available in your system's `PATH`:

* **`aria2c`**: A lightweight multi-protocol download utility (used for fetching CDN files).
* **`ctrtool`**: A tool to extract data from 3DS files and read TMD contents.
* **`makerom`**: A tool to build and repackage `.cia` and `.cci` files.
* **`make_cdn_cia`**: A utility used to pack downloaded CDN contents into a standard `.cia` file.
* **`decrypt`**: The decryption tool used internally by the batch scripts for `.ncch` files.

## Usage

### CIA Downloader

**Windows:**
1. Run `CIA_Downloader.bat`.
2. When prompted, enter the 16-character Title ID of the game you wish to download (e.g., `0004000000030800`).
3. Enter a name for the game to generate the `.cia` file once the download finishes.

**Linux / macOS:**
1. Make the script executable: `chmod +x CIA_Downloader.sh`
2. Run the script: `./CIA_Downloader.sh`
3. Follow the on-screen prompts to enter the Title ID and the desired output name.

*Note: The script features automatic resume functionality. If a download is interrupted, rerunning the script with the same Title ID will resume where it left off.*

### Batch CIA 3DS Decryptor

1. Place all your encrypted `.3ds` or `.cia` files into the same directory as the script.
2. **Windows:** Run `Batch CIA 3DS Decryptor.bat`.
   **Linux / macOS:** Make the script executable (`chmod +x "Batch CIA 3DS Decryptor.sh"`) and run `./Batch CIA 3DS Decryptor.sh`.
3. The script will process all valid files in the folder, outputting a log to `log.txt`.
4. Decrypted files will be generated with a `-decrypted` suffix appended to the filename. Temporary `.ncch` files will be automatically cleaned up after the process finishes.

## Credits

* **Original `.bat` scripts:** matif (2017)
* **Linux/macOS `.sh` ports:** MrTakedi (2026)

## License

This project is licensed under the MIT License. 

Copyright (c) 2017 matif.

See the `LICENSE` file for full details.
