//
//  GalleryConfiguration.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 04/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public struct GalleryConfiguration {
  public init() {}

  /// Allows to stop paging at the beginning and the end of item list or page infinitely in a "carousel" like mode.
  public var pagingMode: GalleryPagingMode = .standard

  /// Distance (width of the area) between images when paged.
  public var imageDividerWidth: CGFloat = 10

  ///Option to set the Close button type.
  public var closeButtonMode: ButtonMode = .builtIn

  ///Option to set the Close button type  within the Thumbnails screen.
  public var seeAllCloseButtonMode: ButtonMode = .builtIn

  ///Option to set the Thumbnails button type.
  public var thumbnailsButtonMode: ButtonMode = .builtIn

  ///Option to set the Delete button type.
  public var deleteButtonMode: ButtonMode = .builtIn

  /// Layout behaviour for the Close button.
  public var closeLayout: ButtonLayout = .pinRight(8, 16)

  /// Layout behaviour for the Close button within the Thumbnails screen.
  public var seeAllCloseLayout: ButtonLayout = .pinRight(8, 16)

  /// Layout behaviour for the Thumbnails button.
  public var thumbnailsLayout: ButtonLayout = .pinLeft(8, 16)

  /// Layout behaviour for the Delete button.
  public var deleteLayout: ButtonLayout = .pinRight(8, 66)

  /// This spinner is shown when we page to an image page, but the image itself is still loading.
  public var spinnerStyle: UIActivityIndicatorView.Style = .medium

  /// Tint color for the spinner.
  public var spinnerColor: UIColor = .white

  /// Layout behaviour for optional header view.
  public var headerViewLayout: HeaderLayout = .center(25)

  /// Layout behaviour for optional footer view.
  public var footerViewLayout: FooterLayout = .center(25)

  /// Sets the status bar visible/invisible while gallery is presented.
  public var statusBarHidden: Bool = true

  /// Sets the close button, header view and footer view visible/invisible on launch. Visibility of these three views is toggled by single tapping anywhere in the gallery area. This setting is global to Gallery.
  public var hideDecorationViewsOnLaunch: Bool = false

  ///Allows to turn on/off decoration views hiding via single tap.
  public var toggleDecorationViewsBySingleTap: Bool = true

  ///Allows to uiactivityviewcontroller with itemview via long press.
  public var activityViewByLongPress: Bool = true

  /// Allows you to select between different types of initial gallery presentation style
  public var presentationStyle: GalleryPresentationStyle = .displacement

  ///Allows to set maximum magnification factor for the image
  public var maximumZoomScale: CGFloat = 8

  ///Sets the duration of the animation when item is double tapped and transitions between ScaleToAspectFit & ScaleToAspectFill sizes.
  public var doubleTapToZoomDuration: TimeInterval = 0.15

  ///Transition duration for the item when the fade-in/fade-out effect is used globally for items while Gallery is being presented /dismissed.
  public var itemFadeDuration: TimeInterval = 0.3

  ///Transition duration for decoration views when they fade-in/fade-out after single tap.
  public var decorationViewsFadeDuration: TimeInterval = 0.15

  ///Duration of animated re-layout after device rotation.
  public var rotationDuration: TimeInterval = 0.15

  /// Duration of the displacement effect when gallery is being presented.
  public var displacementDuration: TimeInterval = 0.55

  /// Duration of the displacement effect when gallery is being dismissed.
  public var reverseDisplacementDuration: TimeInterval = 0.25

  ///Setting this to true is useful when your overlay layer is not fully opaque and you have multiple images on screen at once. The problem is image 1 is going to be displaced (gallery is being presented) and you can see that it is missing in the parent canvas because it "left the canvas" and the canvas bleeds its content through the overlay layer. However when you page to a different image and you decide to dismiss the gallery, that different image is going to be returned (using reverse displacement). That looks a bit strange because it is reverse displacing but it actually is already present in the parent canvas whereas the original image 1 is still missing there. There is no meaningful way to manage these displaced views. This setting helps to avoid it his problem by keeping the originals in place while still using the displacement effect.
  public var displacementKeepOriginalInPlace: Bool = false

  ///Provides the most typical timing curves for the displacement transition.
  public var displacementTimingCurve: UIView.AnimationCurve = .linear

  ///Allows to optionally set a spring bounce when the displacement transition finishes.
  public var displacementTransitionStyle: GalleryDisplacementStyle = .normal

  ///For the image to be reverse displaced, it must be visible in the parent view frame on screen, otherwise it's pointless to do the reverse displacement animation as we would be animating to out of bounds of the screen. However, there might be edge cases where only a tiny percentage of image is visible on screen, so reverse-displacing to that might not be desirable / visually pleasing. To address this problem, we can define a valid area that will be smaller by a given margin and sit centered inside the parent frame. For example, setting a value of 20 means the reverse displaced image must be in a rect that is inside the parent frame and the margin on all sides is to the parent frame is 20 points.
  public var displacementInsetMargin: CGFloat = 50

    public var overlayViewConfiguration: BlurViewConfiguration = .init()

  ///The minimum velocity needed for the image to continue on its swipe-to-dismiss path instead of returning to its original position. The velocity is in scalar units per second, which in our case represents points on screen per second. When the thumb moves on screen and eventually is lifted, it traveled along a path and the speed represents the number of points it traveled in the last 1000 msec before it was lifted.
  public var swipeToDismissThresholdVelocity: CGFloat = 500

  ///Allows to decide direction of swipe to dismiss, or disable it altogether
  public var swipeToDismissMode: GallerySwipeToDismissMode = .always

  ///Allows to set rotation support support with relation to rotation support in the hosting app.
  public var rotationMode: GalleryRotationMode = .always

  ///Allows the video player to automatically continue playing the next video
  public var continuePlayVideoOnEnd: Bool = false

  ///Allows auto play video after gallery presented
  public var videoAutoPlay: Bool = false

  ///Tint color of video controls
  public var videoControlsColor: UIColor = .tintColor
}

public enum GalleryRotationMode {

  ///Gallery will rotate to orientations supported in the application.
  case applicationBased

  ///Gallery will rotate regardless of the rotation setting in the application.
  case always
}

public enum ButtonMode {

  case none
  case builtIn
  /// Standard Close or Thumbnails button.
  case custom(UIButton)
}

public enum GalleryPagingMode {

  case standard
  /// Allows paging through images from 0 to N, when first or last image reached ,horizontal swipe to dismiss kicks in.
  case carousel
  /// Pages through images from 0 to N and the again 0 to N in a loop, works both directions.
}

public enum GalleryDisplacementStyle {

  case normal
  case springBounce(CGFloat)
}

public enum GalleryPresentationStyle {

  case fade
  case displacement
}

public struct GallerySwipeToDismissMode: OptionSet {

  public init(rawValue: Int) { self.rawValue = rawValue }
  public let rawValue: Int

  public static let never = GallerySwipeToDismissMode([])
  public static let horizontal = GallerySwipeToDismissMode(rawValue: 1 << 0)
  public static let vertical = GallerySwipeToDismissMode(rawValue: 1 << 1)
  public static let always: GallerySwipeToDismissMode = [.horizontal, .vertical]
}
