//
//  AVPlayer.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 02/08/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import AVFoundation

extension AVPlayer {
    var isPlaying: Bool {
        rate != 0.0 && status == .readyToPlay
    }
}
