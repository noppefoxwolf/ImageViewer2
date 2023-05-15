//
//  ViewController.swift
//  Example
//
//  Created by Rui Peres on 05/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import UIKit
import PreviewKit

extension UIImageView: DisplaceableView {}

struct DataItem {

    let imageView: UIImageView
    let galleryItem: GalleryItem
}

class ViewController: UIViewController {

    let imageView1 = UIImageView()
    let imageView2 = UIImageView()
    let imageView3 = UIImageView()
    let imageView4 = UIImageView()
    let imageView5 = UIImageView()
    let imageView6 = UIImageView()
    let imageView7 = UIImageView()

    var items: [DataItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView1.image = UIImage(named: "0")
        imageView2.image = UIImage(named: "1")
        imageView3.image = UIImage(named: "2")
        imageView4.image = UIImage(named: "3")
        imageView5.image = UIImage(named: "4")
        imageView6.image = UIImage(named: "5")
        imageView7.image = UIImage(named: "6")

        let imageViews = [imageView1, imageView2, imageView3, imageView4, imageView5, imageView6, imageView7]
        
        let stackView = UIStackView(arrangedSubviews: imageViews)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            view.rightAnchor.constraint(equalTo: stackView.rightAnchor),
        ])
        
        for imageView in imageViews {
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(showGalleryImageViewer))
            imageView.addGestureRecognizer(tapGesture)
            imageView.isUserInteractionEnabled = true
        }

        for (index, imageView) in imageViews.enumerated() {

            var galleryItem: GalleryItem!

            switch index {

            case 2:

                galleryItem = GalleryItem.video(fetchPreviewImageBlock: { UIImage(named: "2")! }, videoURL: URL (string: "https://video.dailymail.co.uk/video/mol/test/2016/09/21/5739239377694275356/1024x576_MP4_5739239377694275356.mp4")!)

            case 4:

                let myFetchImageBlock: FetchImageBlock = { imageView.image! }

                let itemViewControllerBlock: ItemViewControllerBlock = { index, itemCount, fetchImageBlock, configuration, isInitialController in

                    return AnimatedViewController(index: index, itemCount: itemCount, fetchImageBlock: myFetchImageBlock, configuration: configuration, isInitialController: isInitialController)
                }

                galleryItem = GalleryItem.custom(fetchImageBlock: myFetchImageBlock, itemViewControllerBlock: itemViewControllerBlock)

            default:

                let image = imageView.image ?? UIImage(named: "0")!
                galleryItem = GalleryItem.image(fetchPreviewImageBlock: { image }, fetchImageBlock: { image })
            }

            items.append(DataItem(imageView: imageView, galleryItem: galleryItem))
        }
    }

    @IBAction func showGalleryImageViewer(_ sender: UITapGestureRecognizer) {

        guard let displacedView = sender.view as? UIImageView else { return }

        guard let displacedViewIndex = items.firstIndex(where: { $0.imageView == displacedView }) else { return }

        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let headerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: items.count)
        let footerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: items.count)

        let galleryViewController = GalleryViewController(startIndex: displacedViewIndex, itemsDataSource: self, itemsDelegate: self, displacedViewsDataSource: self, configuration: galleryConfiguration())
//        galleryViewController.headerView = headerView
        galleryViewController.footerView = UIView()

        galleryViewController.launchedCompletion = { print("LAUNCHED") }
        galleryViewController.closedCompletion = { print("CLOSED") }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }

        galleryViewController.landedPageAtIndexCompletion = { index in

            print("LANDED AT INDEX: \(index)")

            headerView.count = self.items.count
            headerView.currentIndex = index
            footerView.count = self.items.count
            footerView.currentIndex = index
        }

        self.presentImageGallery(galleryViewController)
    }

    func galleryConfiguration() -> GalleryConfiguration {
        var configuration = GalleryConfiguration()
        configuration.closeButtonMode = .builtIn
        configuration.pagingMode = .standard
        configuration.presentationStyle = .displacement
        configuration.hideDecorationViewsOnLaunch = false
        configuration.swipeToDismissMode = .vertical
        configuration.toggleDecorationViewsBySingleTap = false
        configuration.activityViewByLongPress = false
        configuration.overlayViewConfiguration.overlayColor = UIColor(white: 0.035, alpha: 1)
        configuration.overlayViewConfiguration.overlayColorOpacity = 1
        configuration.overlayViewConfiguration.overlayBlurOpacity = 1
        configuration.overlayViewConfiguration.overlayBlurStyle = UIBlurEffect.Style.light
        configuration.overlayViewConfiguration.blurPresentDuration = 0.5
        configuration.overlayViewConfiguration.blurPresentDelay = 0
        configuration.overlayViewConfiguration.colorPresentDuration = 0.25
        configuration.overlayViewConfiguration.colorPresentDelay = 0
        configuration.overlayViewConfiguration.blurDismissDuration = 0.1
        configuration.overlayViewConfiguration.blurDismissDelay = 0.4
        configuration.overlayViewConfiguration.colorDismissDuration = 0.45
        configuration.overlayViewConfiguration.colorDismissDelay = 0
        configuration.videoControlsColor = .white
        configuration.maximumZoomScale = 8
        configuration.swipeToDismissThresholdVelocity = 500
        configuration.doubleTapToZoomDuration = 0.15
        configuration.itemFadeDuration = 0.3
        configuration.decorationViewsFadeDuration = 0.15
        configuration.rotationDuration = 0.15
        configuration.displacementDuration = 0.55
        configuration.reverseDisplacementDuration = 0.25
        configuration.displacementTransitionStyle = .springBounce(0.7)
        configuration.displacementTimingCurve = .linear
        configuration.statusBarHidden = true
        configuration.displacementKeepOriginalInPlace = false
        configuration.displacementInsetMargin = 50
        return configuration
    }
}

extension ViewController: GalleryDisplacedViewsDataSource {
    func transitionView(at index: Int) -> DisplaceableView? {
        index < items.count ? items[index].imageView : nil
    }
}

extension ViewController: GalleryItemsDataSource {

    func numberOfGalleryItems() -> Int {
        items.count
    }

    func galleryItem(at index: Int) -> GalleryItem {
        items[index].galleryItem
    }
}

extension ViewController: GalleryItemsDelegate {

    func removeGalleryItem(at index: Int) {

        print("remove item at \(index)")

        let imageView = items[index].imageView
        imageView.removeFromSuperview()
        items.remove(at: index)
    }
}

// Some external custom UIImageView we want to show in the gallery
class FLSomeAnimatedImage: UIImageView {
}

// Extend ImageBaseController so we get all the functionality for free
class AnimatedViewController: ItemBaseController<FLSomeAnimatedImage> {
}
