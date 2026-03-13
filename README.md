# NPS Browser for macOS

A Swift 5 implementation of NPS Browser.\
**Tested and working on macOS 10.14+ (Intel and Apple Silicon)**

![](/Screenshots/main.png?raw=true)

## Features
* Localization in Simplified Chinese
* Bookmarks can be saved via the Favourites checkbox in the details panel
* Multi-select downloads: Cmd+click or Shift+click to select multiple items, then download all at once
* Downloads can be started from the bookmark list
* Downloads can be stopped and resumed at any point, they can also be resumed if the app is closed during download
* System notifications when downloads start and when all packages in a batch complete
* Compatibility pack support for FW 3.61+
* Game updates are always the latest version
* Game artwork is displayed

## Usage
* Change or set URLs and extraction preferences in the Preferences window
* From the menu select Database > Reload or press ⌘R
* Compatibility pack URLs must be the raw text file.

## Removal
After moving to trash, run:
```
rm -r ~/Library/Application\ Support/JK3Y.NPS-Browser/
rm -r ~/Library/Caches/JK3Y.NPS-Browser
rm -r ~/Library/Caches/NPS\ Browser
defaults delete JK3Y.NPS-Browser
```

## Building
Make sure you have a recent Xcode (14+) and [Carthage][] installed.
Open a terminal and install the dependencies:
```
carthage bootstrap --platform macOS --no-use-binaries --cache-builds
```
Open the .xcodeproj file to open the project.

Build by going to Product > Build.

Export an app bundle by going to Product > Archive > Export.

#### [Changelog][]

## App icon
* Current app icon: NPS Browser icon by **iigiovanni**, from [macOSicons](https://macosicons.com)

## Thanks
* Ann0ying for the original app icon
* Luro02 for the [pkg2zip][] fork
* devnoname120 for [vitanpupdatelinks][]
* L1cardo for Simplified Chinese translation

[Carthage]: https://github.com/Carthage/Carthage
[Changelog]: CHANGELOG.md
[pkg2zip]: https://github.com/Luro02/pkg2zip
[vitanpupdatelinks]: https://github.com/devnoname120/vitanpupdatelinks
