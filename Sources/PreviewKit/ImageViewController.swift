//
//  ImageViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 15/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

extension UIImageView: ItemView {}

class ImageViewController: ItemBaseController<UIImageView> {
    let fetchPreviewImageBlock: FetchImageBlock?

    init(
        index: Int,
        itemCount: Int,
        fetchPreviewImageBlock: FetchImageBlock?,
        fetchImageBlock: @escaping FetchImageBlock,
        configuration: GalleryConfiguration,
        isInitialController: Bool = false
    ) {
        self.fetchPreviewImageBlock = fetchPreviewImageBlock
        super
            .init(
                index: index,
                itemCount: itemCount,
                fetchImageBlock: fetchImageBlock,
                configuration: configuration
            )
    }

    override func fetchImage() async {
        let previewTask = Task {
            await self.fetchPreviewImage()
        }
        await super.fetchImage()
        previewTask.cancel()
    }

    func fetchPreviewImage() async {
        defer { activityIndicatorView.stopAnimating() }
        guard let image = await fetchPreviewImageBlock?() else { return }
        guard itemView.image == nil else { return }
        itemView.image = image
        itemView.isAccessibilityElement = image.isAccessibilityElement
        itemView.accessibilityLabel = image.accessibilityLabel
        itemView.accessibilityTraits = image.accessibilityTraits

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}
