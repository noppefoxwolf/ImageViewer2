//
//  UIButton.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 28/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

extension UIButton {

    static func circlePlayButton(_ diameter: CGFloat) -> UIButton {

        let button = UIButton(type: .custom)
        button.frame = CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter))

        let circleImageNormal = CAShapeLayer.circlePlayShape(UIColor.white, diameter: diameter).toImage()
        button.setImage(circleImageNormal, for: .normal)

        let circleImageHighlighted = CAShapeLayer.circlePlayShape(UIColor.lightGray, diameter: diameter).toImage()
        button.setImage(circleImageHighlighted, for: .highlighted)

        return button
    }

    static func replayButton(width: CGFloat, height: CGFloat) -> UIButton {

        let button = UIButton(type: .custom)
        button.bounds.size = CGSize(width: width, height: height)
        
        button.configuration = UIButton.Configuration.plain()
        button.configuration?.image = UIImage(systemName: "play.fill")

        return button
    }

    static func playButton(width: CGFloat, height: CGFloat) -> UIButton {

        let button = UIButton(type: .custom)
        button.bounds.size = CGSize(width: width, height: height)
        button.contentHorizontalAlignment = .center
        button.configuration = UIButton.Configuration.plain()
        button.configuration?.image = UIImage(systemName: "play.fill")
        
        return button
    }

    static func pauseButton(width: CGFloat, height: CGFloat) -> UIButton {
        let button = UIButton(type: .custom)
        button.configuration = UIButton.Configuration.plain()
        button.configuration?.image = UIImage(systemName: "pause.fill")
        button.configuration?.baseForegroundColor = .white
        return button
    }

    static func closeButton() -> UIButton {
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
        button.configuration = UIButton.Configuration.plain()
        button.configuration?.image = UIImage(systemName: "xmark")
        button.configuration?.baseForegroundColor = .white
        return button
    }

    static func thumbnailsButton() -> UIButton {

        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 80, height: 50)))
        button.setTitle("See All", for: .normal)

        return button
    }

    static func deleteButton() -> UIButton {

        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 80, height: 50)))
        button.setTitle("Delete", for: .normal)

        return button
    }
}
