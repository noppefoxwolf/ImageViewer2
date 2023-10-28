//
//  CALayer.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

extension CALayer {

    func toImage() -> UIImage {
        UIGraphicsImageRenderer(size: frame.size)
            .image(actions: { context in
                self.render(in: context.cgContext)
            })
    }
}
