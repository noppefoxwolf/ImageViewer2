//
//  BlurView.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public struct BlurViewConfiguration {
  public init() {}

  ///Base color of the overlay layer that is mostly visible when images are displaced (gallery is being presented), rotated and interactively dismissed.
  public var overlayColor: UIColor = .black

  ///Allows to select the overall tone on the B&W scale of the blur layer in the overlay.
  public var overlayBlurStyle: UIBlurEffect.Style = .light

  ///The opacity of overlay layer when the displacement effect finishes anf the gallery is fully presented. Valid values are from 0 to 1 where 1 is full opacity i.e the overlay layer is fully opaque, 0 is completely transparent and effectively invisible.
  public var overlayBlurOpacity: CGFloat = 1

  ///The opacity of overlay layer when the displacement effect finishes anf the gallery is fully presented. Valid values are from 0 to 1 where 1 is full opacity i.e the overlay layer is fully opaque, 0 is completely transparent and effectively invisible.
  public var overlayColorOpacity: CGFloat = 1

  ///Transition duration for the blur layer component of the overlay when Gallery is being presented.
  public var blurPresentDuration: TimeInterval = 0.5

  ///Delayed start for the transition of the blur layer component of the overlay when Gallery is being presented.
  public var blurPresentDelay: TimeInterval = 0

  ///Transition duration for the color layer component of the overlay when Gallery is being presented.
  public var colorPresentDuration: TimeInterval = 0.25

  ///Delayed start for the transition of color layer component of the overlay when Gallery is being presented.
  public var colorPresentDelay: TimeInterval = 0

  ///Transition duration for the blur layer component of the overlay when Gallery is being dismissed.
  public var blurDismissDuration: TimeInterval = 0.1

  ///Transition delay for the blur layer component of the overlay when Gallery is being dismissed.
  public var blurDismissDelay: TimeInterval = 0.4

  ///Transition duration for the color layer component of the overlay when Gallery is being dismissed.
  public var colorDismissDuration: TimeInterval = 0.45

  ///Transition delay for the color layer component of the overlay when Gallery is being dismissed.
  public var colorDismissDelay: TimeInterval = 0
}

class BlurView: UIView {

  let configuration: BlurViewConfiguration

  var blurTargetOpacity: CGFloat = 1
  var colorTargetOpacity: CGFloat = 1

  let blurringViewContainer = UIView()  //serves as a transparency container for the blurringView as it's not recommended by Apple to apply transparency directly to the UIVisualEffectsView
  let blurringView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
  let colorView = UIView()

  init(configuration: BlurViewConfiguration) {
    self.configuration = configuration
    super.init(frame: .null)

    blurringViewContainer.alpha = 0

    colorView.backgroundColor = configuration.overlayColor
    colorView.alpha = 0

    self.addSubview(blurringViewContainer)
    blurringViewContainer.addSubview(blurringView)
    self.addSubview(colorView)
  }

  @available(iOS, unavailable)
  required init?(coder aDecoder: NSCoder) { fatalError() }

  override func layoutSubviews() {
    super.layoutSubviews()

    blurringViewContainer.frame = self.bounds
    blurringView.frame = blurringViewContainer.bounds
    colorView.frame = self.bounds
  }

  func present() {

    UIView.animate(
      withDuration: configuration.blurPresentDuration, delay: configuration.blurPresentDelay,
      options: .curveLinear,
      animations: { [weak self] in
        guard let self else { return }
        self.blurringViewContainer.alpha = self.blurTargetOpacity

      }, completion: nil)

    UIView.animate(
      withDuration: configuration.colorPresentDuration, delay: configuration.colorPresentDelay,
      options: .curveLinear,
      animations: { [weak self] in
        guard let self else { return }
        self.colorView.alpha = self.colorTargetOpacity

      }, completion: nil)
  }

  func dismiss() {

    UIView.animate(
      withDuration: configuration.blurDismissDuration, delay: configuration.blurDismissDelay,
      options: .curveLinear,
      animations: { [weak self] in

        self?.blurringViewContainer.alpha = 0

      }, completion: nil)

    UIView.animate(
      withDuration: configuration.colorDismissDuration, delay: configuration.colorDismissDelay,
      options: .curveLinear,
      animations: { [weak self] in

        self?.colorView.alpha = 0

      }, completion: nil)
  }
}
