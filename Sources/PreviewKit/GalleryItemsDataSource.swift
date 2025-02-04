//
//  GalleryItemsDataSource.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 18/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public protocol GalleryItemsDataSource: AnyObject {
    func numberOfGalleryItems() -> Int
    func galleryItem(at index: Int) -> GalleryItem
}
