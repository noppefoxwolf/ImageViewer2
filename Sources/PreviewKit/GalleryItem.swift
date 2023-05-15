//
//  GalleryItem.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public typealias FetchImageBlock = () async -> UIImage?
public typealias ItemViewControllerBlock = (
  _ index: Int, _ itemCount: Int, _ fetchImageBlock: FetchImageBlock,
  _ configuration: GalleryConfiguration, _ isInitialController: Bool
) -> UIViewController

public enum GalleryItem {

  case image(fetchPreviewImageBlock: FetchImageBlock?, fetchImageBlock: FetchImageBlock)
  case video(fetchPreviewImageBlock: FetchImageBlock, videoURL: URL)
  case custom(fetchImageBlock: FetchImageBlock, itemViewControllerBlock: ItemViewControllerBlock)
}
