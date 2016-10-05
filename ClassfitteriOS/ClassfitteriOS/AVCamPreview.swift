//
//  AVCamPreview.swift
//  ClassfitteriOS
//
//  Created by James Wood on 04/10/2016.
//  Copyright © 2016 James Wood. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class AVCamPreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    var session: AVCaptureSession? {
        get {
            return (self.layer as! AVCaptureVideoPreviewLayer).session
        }
        set (session) {
            (self.layer as! AVCaptureVideoPreviewLayer).session = session
        }
    }
}
