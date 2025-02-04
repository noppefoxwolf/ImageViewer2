//
//  GalleryPagingDataSource.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 15/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

final class GalleryPagingDataSource: NSObject, UIPageViewControllerDataSource {

    weak var itemControllerDelegate: ItemControllerDelegate?
    private weak var itemsDataSource: GalleryItemsDataSource?
    private weak var displacedViewsDataSource: GalleryDisplacedViewsDataSource?

    private let configuration: GalleryConfiguration
    private var pagingMode = GalleryPagingMode.standard
    private var itemCount: Int {
        itemsDataSource?.numberOfGalleryItems() ?? 0
    }
    private unowned var scrubber: VideoScrubber

    init(
        itemsDataSource: GalleryItemsDataSource,
        displacedViewsDataSource: GalleryDisplacedViewsDataSource?,
        scrubber: VideoScrubber,
        configuration: GalleryConfiguration
    ) {

        self.itemsDataSource = itemsDataSource
        self.displacedViewsDataSource = displacedViewsDataSource
        self.scrubber = scrubber
        self.configuration = configuration

        if itemsDataSource.numberOfGalleryItems() > 1 {  // Potential carousel mode present in configuration only makes sense for more than 1 item
            pagingMode = configuration.pagingMode
        }
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {

        guard let currentController = viewController as? ItemController else { return nil }
        let previousIndex =
            (currentController.index == 0) ? itemCount - 1 : currentController.index - 1

        switch pagingMode {

        case .standard:
            return (currentController.index > 0) ? self.createItemController(previousIndex) : nil

        case .carousel:
            return self.createItemController(previousIndex)
        }
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {

        guard let currentController = viewController as? ItemController else { return nil }
        let nextIndex = (currentController.index == itemCount - 1) ? 0 : currentController.index + 1

        switch pagingMode {

        case .standard:
            return (currentController.index < itemCount - 1)
                ? self.createItemController(nextIndex) : nil

        case .carousel:
            return self.createItemController(nextIndex)
        }
    }

    func createItemController(_ itemIndex: Int, isInitial: Bool = false) -> UIViewController {

        guard let itemsDataSource else { return UIViewController() }

        let item = itemsDataSource.galleryItem(at: itemIndex)

        switch item {

        case .image(let fetchPreviewImageBlock, let fetchImageBlock):

            let imageController = ImageViewController(
                index: itemIndex,
                itemCount: itemsDataSource.numberOfGalleryItems(),
                fetchPreviewImageBlock: fetchPreviewImageBlock,
                fetchImageBlock: fetchImageBlock,
                configuration: configuration,
                isInitialController: isInitial
            )
            imageController.delegate = itemControllerDelegate
            imageController.displacedViewsDataSource = displacedViewsDataSource

            return imageController

        case .video(let fetchImageBlock, let videoURL):

            let videoController = VideoViewController(
                index: itemIndex,
                itemCount: itemsDataSource.numberOfGalleryItems(),
                fetchImageBlock: fetchImageBlock,
                videoURL: videoURL,
                scrubber: scrubber,
                configuration: configuration,
                isInitialController: isInitial
            )

            videoController.delegate = itemControllerDelegate
            videoController.displacedViewsDataSource = displacedViewsDataSource

            return videoController

        case .custom(let fetchImageBlock, let itemViewControllerBlock):

            guard
                let itemController = itemViewControllerBlock(
                    itemIndex,
                    itemsDataSource.numberOfGalleryItems(),
                    fetchImageBlock,
                    configuration,
                    isInitial
                )
                    as? ItemController, let vc = itemController as? UIViewController
            else { return UIViewController() }

            itemController.delegate = itemControllerDelegate
            itemController.displacedViewsDataSource = displacedViewsDataSource

            return vc
        }
    }
}
