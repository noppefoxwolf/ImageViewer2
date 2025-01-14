
[![CI Status](http://img.shields.io/travis/Krisiacik/ImageViewer.svg?style=flat)](https://travis-ci.org/Krisiacik/ImageViewer)
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-green.svg?style=flat)](https://developer.apple.com/swift/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/ImageViewer.svg?style=flat)](http://cocoadocs.org/docsets/ImageViewer)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://opensource.org/licenses/MIT)

![Single image view](https://github.com/Krisiacik/ImageViewer/blob/master/Documentation/single.gif)

![Gallery](https://github.com/Krisiacik/ImageViewer/blob/master/Documentation/gallery.gif)

For the latest changes see the [CHANGELOG](CHANGELOG.md)

## Install

### Swift Package Manager

```swift
.package(url: "https://github.com/noppefoxwolf/PreviewKit", branch: "main"),
```


## Sample Usage

For a detailed example, see the [Example](https://github.com/Krisiacik/ImageViewer/tree/master/Example)!

```swift
// Show the ImageViewer with the first item
self.presentImageGallery(GalleryViewController(startIndex: 0, itemsDataSource: self))

// The GalleryItemsDataSource provides the items to show
extension ViewController: GalleryItemsDataSource {
    func numberOfGalleryItems() -> Int {
        return items.count
    }

    func galleryItem(at index: Int) -> GalleryItem {
        return items[index].galleryItem
    }
}

```

### ImageViewer version vs Swift version.

ImageViewer 6.0+ is Swift 5 ready! 🎉

If you use earlier version of Swift - refer to the table below:

| Swift version | ImageViewer version               |
| ------------- | --------------------------------- |
| 5.x           | >= 6.0                            |
| 4.x           | 5.0                               |
| 3.x           | 4.0                               |
| 2.3           | 3.1 [⚠️](CHANGELOG.md#version-31) |
| 2.2           | <= 2.1                            |

## License

ImageViewer is licensed under the MIT License, Version 2.0. See the [LICENSE](LICENSE) file for more info.

Copyright (c) 2016 MailOnline
