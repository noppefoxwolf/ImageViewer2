//
//  GalleryViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import AVFoundation
import UIKit

open class GalleryViewController: UIPageViewController, ItemControllerDelegate {

    // UI
    private let overlayView: BlurView
    /// A custom view on the top of the gallery with layout using default (or custom) pinning settings for header.
    open var headerView: UIView?
    /// A custom view at the bottom of the gallery with layout using default (or custom) pinning settings for footer.
    open var footerView: UIView?
    private var closeButton: UIButton? = UIButton.closeButton()
    private var seeAllCloseButton: UIButton? = nil
    private var thumbnailsButton: UIButton? = UIButton.thumbnailsButton()
    private var deleteButton: UIButton? = UIButton.deleteButton()
    private let scrubber = VideoScrubber()

    private weak var initialItemController: ItemController?

    // LOCAL STATE
    // represents the current page index, updated when the root view of the view controller representing the page stops animating inside visible bounds and stays on screen.
    public var currentIndex: Int
    // Picks up the initial value from configuration, if provided. Subsequently also works as local state for the setting.
    private var decorationViewsHidden = false
    private var isAnimating = false
    private var initialPresentationDone = false

    // DATASOURCE/DELEGATE
    private let itemsDelegate: GalleryItemsDelegate?
    private let itemsDataSource: GalleryItemsDataSource
    private let pagingDataSource: GalleryPagingDataSource

    // CONFIGURATION
    private let configuration: GalleryConfiguration

    /// COMPLETION BLOCKS
    /// If set, the block is executed right after the initial launch animations finish.
    open var launchedCompletion: (() -> Void)?
    /// If set, called every time ANY animation stops in the page controller stops and the viewer passes a page index of the page that is currently on screen
    open var landedPageAtIndexCompletion: ((Int) -> Void)?
    /// If set, launched after all animations finish when the close button is pressed.
    open var closedCompletion: (() -> Void)?
    /// If set, launched after all animations finish when the close() method is invoked via public API.
    open var programmaticallyClosedCompletion: (() -> Void)?
    /// If set, launched after all animations finish when the swipe-to-dismiss (applies to all directions and cases) gesture is used.
    open var swipedToDismissCompletion: (() -> Void)?

    @available(*, unavailable)
    required public init?(coder: NSCoder) { fatalError() }

    public init(
        startIndex: Int = 0,
        itemsDataSource: GalleryItemsDataSource,
        itemsDelegate: GalleryItemsDelegate? = nil,
        displacedViewsDataSource: GalleryDisplacedViewsDataSource? = nil,
        configuration: GalleryConfiguration = .init()
    ) {

        self.currentIndex = startIndex
        self.itemsDelegate = itemsDelegate
        self.itemsDataSource = itemsDataSource
        self.configuration = configuration
        self.overlayView = BlurView(configuration: configuration.overlayViewConfiguration)

        let continueNextVideoOnFinish = configuration.continuePlayVideoOnEnd
        scrubber.tintColor = configuration.videoControlsColor
        switch configuration.closeButtonMode {
        case .none: closeButton = nil
        case .custom(let button): closeButton = button
        case .builtIn: break
        }

        switch configuration.seeAllCloseButtonMode {
        case .none: seeAllCloseButton = nil
        case .custom(let button): seeAllCloseButton = button
        case .builtIn: break
        }

        switch configuration.thumbnailsButtonMode {
        case .none: thumbnailsButton = nil
        case .custom(let button): thumbnailsButton = button
        case .builtIn: break
        }

        switch configuration.deleteButtonMode {
        case .none: deleteButton = nil
        case .custom(let button): deleteButton = button
        case .builtIn: break
        }

        pagingDataSource = GalleryPagingDataSource(
            itemsDataSource: itemsDataSource,
            displacedViewsDataSource: displacedViewsDataSource,
            scrubber: scrubber,
            configuration: configuration
        )

        super
            .init(
                transitionStyle: UIPageViewController.TransitionStyle.scroll,
                navigationOrientation: UIPageViewController.NavigationOrientation.horizontal,
                options: [
                    UIPageViewController.OptionsKey.interPageSpacing: configuration
                        .imageDividerWidth
                ]
            )

        pagingDataSource.itemControllerDelegate = self

        ///This feels out of place, one would expect even the first presented(paged) item controller to be provided by the paging dataSource but there is nothing we can do as Apple requires the first controller to be set via this "setViewControllers" method.
        let initialController = pagingDataSource.createItemController(startIndex, isInitial: true)
        self.setViewControllers(
            [initialController],
            direction: UIPageViewController.NavigationDirection.forward,
            animated: false,
            completion: nil
        )

        if let controller = initialController as? ItemController {

            initialItemController = controller
        }

        ///This less known/used presentation style option allows the contents of parent view controller presenting the gallery to "bleed through" the blurView. Otherwise we would see only black color.
        self.modalPresentationStyle = .overFullScreen
        self.dataSource = pagingDataSource

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(GalleryViewController.rotate),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )

        if continueNextVideoOnFinish {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didEndPlaying),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: nil
            )
        }
    }

    deinit {

        NotificationCenter.default.removeObserver(self)
    }

    @objc func didEndPlaying() {
        page(toIndex: currentIndex + 1)
    }

    private func configureOverlayView() {

        overlayView.bounds.size =
            UIScreen.main.bounds
            .insetBy(
                dx: -UIScreen.main.bounds.width / 2,
                dy: -UIScreen.main.bounds.height / 2
            )
            .size
        overlayView.center = CGPoint(
            x: (UIScreen.main.bounds.width / 2),
            y: (UIScreen.main.bounds.height / 2)
        )

        self.view.addSubview(overlayView)
        self.view.sendSubviewToBack(overlayView)
    }

    private func configureHeaderView() {

        if let headerView {
            headerView.alpha = 0
            self.view.addSubview(headerView)
        }
    }

    private func configureFooterView() {

        if let footerView {
            footerView.alpha = 0
            self.view.addSubview(footerView)
        }
    }

    private func configureCloseButton() {

        if let closeButton {
            closeButton.addTarget(
                self,
                action: #selector(GalleryViewController.closeInteractively),
                for: .touchUpInside
            )
            closeButton.alpha = 0
            self.view.addSubview(closeButton)
        }
    }

    private func configureThumbnailsButton() {

        if let thumbnailsButton {
            thumbnailsButton.addTarget(
                self,
                action: #selector(GalleryViewController.showThumbnails),
                for: .touchUpInside
            )
            thumbnailsButton.alpha = 0
            self.view.addSubview(thumbnailsButton)
        }
    }

    private func configureDeleteButton() {

        if let deleteButton {
            deleteButton.addTarget(
                self,
                action: #selector(GalleryViewController.deleteItem),
                for: .touchUpInside
            )
            deleteButton.alpha = 0
            self.view.addSubview(deleteButton)
        }
    }

    private func configureScrubber() {

        scrubber.alpha = 0
        self.view.addSubview(scrubber)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        configureHeaderView()
        configureFooterView()
        configureCloseButton()
        configureThumbnailsButton()
        configureDeleteButton()
        configureScrubber()

        self.view.clipsToBounds = false
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard initialPresentationDone == false else { return }

        ///We have to call this here (not sooner), because it adds the overlay view to the presenting controller and the presentingController property is set only at this moment in the VC lifecycle.
        configureOverlayView()

        ///The initial presentation animations and transitions
        presentInitially()

        initialPresentationDone = true
    }

    private func presentInitially() {

        isAnimating = true

        ///Animates decoration views to the initial state if they are set to be visible on launch. We do not need to do anything if they are set to be hidden because they are already set up as hidden by default. Unhiding them for the launch is part of chosen UX.
        initialItemController?
            .presentItem(
                alongsideAnimation: { [weak self] in

                    self?.overlayView.present()

                },
                completion: { [weak self] in

                    if let self {

                        if self.decorationViewsHidden == false {

                            self.animateDecorationViews(visible: true)
                        }

                        self.isAnimating = false

                        self.launchedCompletion?()
                    }
                }
            )
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if configuration.rotationMode == .always && UIApplication.isPortraitOnly {

            let transform = windowRotationTransform()
            let bounds = rotationAdjustedBounds()

            self.view.transform = transform
            self.view.bounds = bounds
        }

        overlayView.frame = view.bounds.insetBy(
            dx: -UIScreen.main.bounds.width * 2,
            dy: -UIScreen.main.bounds.height * 2
        )

        layoutButton(closeButton, layout: configuration.closeLayout)
        layoutButton(thumbnailsButton, layout: configuration.thumbnailsLayout)
        layoutButton(deleteButton, layout: configuration.deleteLayout)
        layoutHeaderView()
        layoutFooterView()
        layoutScrubber()
    }

    private var defaultInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets
        } else {
            return UIEdgeInsets(
                top: configuration.statusBarHidden ? 0.0 : 20.0,
                left: 0.0,
                bottom: 0.0,
                right: 0.0
            )
        }
    }

    private func layoutButton(_ button: UIButton?, layout: ButtonLayout) {

        guard let button else { return }

        switch layout {

        case .pinRight(let marginTop, let marginRight):

            button.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
            button.frame.origin.x =
                self.view.bounds.size.width - marginRight - button.bounds.size.width
            button.frame.origin.y = defaultInsets.top + marginTop

        case .pinLeft(let marginTop, let marginLeft):

            button.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
            button.frame.origin.x = marginLeft
            button.frame.origin.y = defaultInsets.top + marginTop
        }
    }

    private func layoutHeaderView() {

        guard let headerView else { return }

        switch configuration.headerViewLayout {

        case .center(let marginTop):

            headerView.autoresizingMask = [
                .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin,
            ]
            headerView.center = self.view.boundsCenter
            headerView.frame.origin.y = defaultInsets.top + marginTop

        case .pinBoth(let marginTop, let marginLeft, let marginRight):

            headerView.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
            headerView.bounds.size.width = self.view.bounds.width - marginLeft - marginRight
            headerView.sizeToFit()
            headerView.frame.origin = CGPoint(x: marginLeft, y: defaultInsets.top + marginTop)

        case .pinLeft(let marginTop, let marginLeft):

            headerView.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
            headerView.frame.origin = CGPoint(x: marginLeft, y: defaultInsets.top + marginTop)

        case .pinRight(let marginTop, let marginRight):

            headerView.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
            headerView.frame.origin = CGPoint(
                x: self.view.bounds.width - marginRight - headerView.bounds.width,
                y: defaultInsets.top + marginTop
            )
        }
    }

    private func layoutFooterView() {

        guard let footerView else { return }

        switch configuration.footerViewLayout {

        case .center(let marginBottom):

            footerView.autoresizingMask = [
                .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin,
            ]
            footerView.center = self.view.boundsCenter
            footerView.frame.origin.y =
                self.view.bounds.height - footerView.bounds.height - marginBottom
                - defaultInsets.bottom

        case .pinBoth(let marginBottom, let marginLeft, let marginRight):

            footerView.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
            footerView.frame.size.width = self.view.bounds.width - marginLeft - marginRight
            footerView.sizeToFit()
            footerView.frame.origin = CGPoint(
                x: marginLeft,
                y: self.view.bounds.height - footerView.bounds.height - marginBottom
                    - defaultInsets.bottom
            )

        case .pinLeft(let marginBottom, let marginLeft):

            footerView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
            footerView.frame.origin = CGPoint(
                x: marginLeft,
                y: self.view.bounds.height - footerView.bounds.height - marginBottom
                    - defaultInsets.bottom
            )

        case .pinRight(let marginBottom, let marginRight):

            footerView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
            footerView.frame.origin = CGPoint(
                x: self.view.bounds.width - marginRight - footerView.bounds.width,
                y: self.view.bounds.height - footerView.bounds.height - marginBottom
                    - defaultInsets.bottom
            )
        }
    }

    private func layoutScrubber() {

        scrubber.bounds = CGRect(
            origin: CGPoint.zero,
            size: CGSize(width: self.view.bounds.width, height: 40)
        )
        scrubber.center = self.view.boundsCenter
        scrubber.frame.origin.y =
            (footerView?.frame.origin.y ?? self.view.bounds.maxY) - scrubber.bounds.height
    }

    @objc private func deleteItem() {

        deleteButton?.isEnabled = false
        view.isUserInteractionEnabled = false

        itemsDelegate?.removeGalleryItem(at: currentIndex)
        removePage(atIndex: currentIndex) {

            [weak self] in
            self?.deleteButton?.isEnabled = true
            self?.view.isUserInteractionEnabled = true
        }
    }

    //ThumbnailsimageBlock

    @objc private func showThumbnails() {

        let thumbnailsController = ThumbnailsViewController(itemsDataSource: self.itemsDataSource)

        if let seeAllCloseButton {
            thumbnailsController.closeButton = seeAllCloseButton
            thumbnailsController.closeLayout = configuration.seeAllCloseLayout
        } else if let closeButton {
            let seeAllCloseButton = UIButton(
                frame: CGRect(origin: CGPoint.zero, size: closeButton.bounds.size)
            )
            seeAllCloseButton.setImage(
                closeButton.image(for: UIControl.State()),
                for: UIControl.State()
            )
            seeAllCloseButton.setImage(closeButton.image(for: .highlighted), for: .highlighted)
            thumbnailsController.closeButton = seeAllCloseButton
            thumbnailsController.closeLayout = configuration.closeLayout
        }

        thumbnailsController.onItemSelected = { [weak self] index in

            self?.page(toIndex: index)
        }

        present(thumbnailsController, animated: true, completion: nil)
    }

    open func page(toIndex index: Int) {

        guard
            currentIndex != index && index >= 0
                && index < self.itemsDataSource.numberOfGalleryItems()
        else {
            return
        }

        let imageViewController = self.pagingDataSource.createItemController(index)
        let direction: UIPageViewController.NavigationDirection =
            index > currentIndex ? .forward : .reverse

        // workaround to make UIPageViewController happy
        if direction == .forward {
            let previousVC = self.pagingDataSource.createItemController(index - 1)
            setViewControllers(
                [previousVC],
                direction: direction,
                animated: true,
                completion: { finished in
                    DispatchQueue.main.async(execute: { [weak self] in
                        self?
                            .setViewControllers(
                                [imageViewController],
                                direction: direction,
                                animated: false,
                                completion: nil
                            )
                    })
                }
            )
        } else {
            let nextVC = self.pagingDataSource.createItemController(index + 1)
            setViewControllers(
                [nextVC],
                direction: direction,
                animated: true,
                completion: { finished in
                    DispatchQueue.main.async(execute: { [weak self] in
                        self?
                            .setViewControllers(
                                [imageViewController],
                                direction: direction,
                                animated: false,
                                completion: nil
                            )
                    })
                }
            )
        }
    }

    func removePage(atIndex index: Int, completion: @escaping () -> Void) {

        // If removing last item, go back, otherwise, go forward

        let direction: UIPageViewController.NavigationDirection =
            index < self.itemsDataSource.numberOfGalleryItems() ? .forward : .reverse

        let newIndex = direction == .forward ? index : index - 1

        if newIndex < 0 {
            close()
            return
        }

        let vc = self.pagingDataSource.createItemController(newIndex)
        setViewControllers([vc], direction: direction, animated: true) { _ in completion() }
    }

    open func reload(atIndex index: Int) {

        guard index >= 0 && index < self.itemsDataSource.numberOfGalleryItems() else { return }

        guard let firstVC = viewControllers?.first, let itemController = firstVC as? ItemController
        else { return }

        Task {
            await itemController.fetchImage()
        }
    }

    // MARK: - Animations

    @objc private func rotate() {

        /// If the app supports rotation on global level, we don't need to rotate here manually because the rotation
        /// of key Window will rotate all app's content with it via affine transform and from the perspective of the
        /// gallery it is just a simple relayout. Allowing access to remaining code only makes sense if the app is
        /// portrait only but we still want to support rotation inside the gallery.
        guard UIApplication.isPortraitOnly else { return }

        guard UIDevice.current.orientation.isFlat == false && isAnimating == false else { return }

        isAnimating = true

        UIView.animate(
            withDuration: configuration.rotationDuration,
            delay: 0,
            options: UIView.AnimationOptions.curveLinear,
            animations: { [weak self] () -> Void in

                self?.view.transform = windowRotationTransform()
                self?.view.bounds = rotationAdjustedBounds()
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()

            }
        ) { [weak self] finished in

            self?.isAnimating = false
        }
    }

    /// Invoked when closed programmatically
    open func close() {

        closeDecorationViews(programmaticallyClosedCompletion)
    }

    /// Invoked when closed via close button
    @objc private func closeInteractively() {

        closeDecorationViews(closedCompletion)
    }

    private func closeDecorationViews(_ completion: (() -> Void)?) {

        guard isAnimating == false else { return }
        isAnimating = true

        if let itemController = self.viewControllers?.first as? ItemController {

            itemController.closeDecorationViews(configuration.decorationViewsFadeDuration)
        }

        UIView.animate(
            withDuration: configuration.decorationViewsFadeDuration,
            animations: { [weak self] in

                self?.headerView?.alpha = 0.0
                self?.footerView?.alpha = 0.0
                self?.closeButton?.alpha = 0.0
                self?.thumbnailsButton?.alpha = 0.0
                self?.deleteButton?.alpha = 0.0
                self?.scrubber.alpha = 0.0

            },
            completion: { [weak self] done in

                if let strongSelf = self,
                    let itemController = strongSelf.viewControllers?.first as? ItemController
                {

                    itemController.dismissItem(
                        alongsideAnimation: {

                            strongSelf.overlayView.dismiss()

                        },
                        completion: { [weak self] in

                            self?.isAnimating = true
                            self?.closeGallery(false, completion: completion)
                        }
                    )
                }
            }
        )
    }

    func closeGallery(_ animated: Bool, completion: (() -> Void)?) {

        self.overlayView.removeFromSuperview()

        self.modalTransitionStyle = .crossDissolve

        self.dismiss(animated: animated) {
            completion?()
        }
    }

    private func animateDecorationViews(visible: Bool) {

        let targetAlpha: CGFloat = (visible) ? 1 : 0

        UIView.animate(
            withDuration: configuration.decorationViewsFadeDuration,
            animations: { [weak self] in

                self?.headerView?.alpha = targetAlpha
                self?.footerView?.alpha = targetAlpha
                self?.closeButton?.alpha = targetAlpha
                self?.thumbnailsButton?.alpha = targetAlpha
                self?.deleteButton?.alpha = targetAlpha

                if let _ = self?.viewControllers?.first as? VideoViewController {

                    UIView.animate(
                        withDuration: 0.3,
                        animations: { [weak self] in

                            self?.scrubber.alpha = targetAlpha
                        }
                    )
                }
            }
        )
    }

    public func itemControllerWillAppear(_ controller: ItemController) {

        if let videoController = controller as? VideoViewController {

            scrubber.player = videoController.player
        }
    }

    public func itemControllerWillDisappear(_ controller: ItemController) {

        if let _ = controller as? VideoViewController {

            scrubber.player = nil

            UIView.animate(
                withDuration: 0.3,
                animations: { [weak self] in

                    self?.scrubber.alpha = 0
                }
            )
        }
    }

    public func itemControllerDidAppear(_ controller: ItemController) {

        self.currentIndex = controller.index
        self.landedPageAtIndexCompletion?(self.currentIndex)
        self.headerView?.sizeToFit()
        self.footerView?.sizeToFit()

        if let videoController = controller as? VideoViewController {
            scrubber.player = videoController.player
            if scrubber.alpha == 0 && decorationViewsHidden == false {

                UIView.animate(
                    withDuration: 0.3,
                    animations: { [weak self] in

                        self?.scrubber.alpha = 1
                    }
                )
            }
        }
    }

    open func itemControllerDidSingleTap(_ controller: ItemController) {

        self.decorationViewsHidden.toggle()
        animateDecorationViews(visible: !self.decorationViewsHidden)
    }

    open func itemControllerDidLongPress(_ controller: ItemController, in item: ItemView) {
        switch (controller, item) {

        case (_ as ImageViewController, let item as UIImageView):
            guard let image = item.image else { return }
            let activityVC = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            self.present(activityVC, animated: true)

        case (_ as VideoViewController, let item as VideoView):
            guard let videoUrl = ((item.player?.currentItem?.asset) as? AVURLAsset)?.url else {
                return
            }
            let activityVC = UIActivityViewController(
                activityItems: [videoUrl],
                applicationActivities: nil
            )
            self.present(activityVC, animated: true)

        default: return
        }
    }

    public func itemController(
        _ controller: ItemController,
        didSwipeToDismissWithDistanceToEdge distance: CGFloat
    ) {

        if decorationViewsHidden == false {

            let alpha = 1 - distance * configuration.swipeToDismissThresholdVelocity

            closeButton?.alpha = alpha
            thumbnailsButton?.alpha = alpha
            deleteButton?.alpha = alpha
            headerView?.alpha = alpha
            footerView?.alpha = alpha

            if controller is VideoViewController {
                scrubber.alpha = alpha
            }
        }

        self.overlayView.blurringView.alpha = 1 - distance
        self.overlayView.colorView.alpha = 1 - distance
    }

    public func itemControllerDidFinishSwipeToDismissSuccessfully() {

        self.swipedToDismissCompletion?()
        self.overlayView.removeFromSuperview()
        self.dismiss(animated: false, completion: nil)
    }
}
