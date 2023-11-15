//
//  CaptureModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/15.
//


import Foundation
import os

enum CloudButtonState {
    case upload, uploading, processing, download, downloading, downloaded
}

struct CaptureModel: Identifiable {
    var id:UUID
    var isExist:Bool = false
    var isRawMeshExist:Bool = false
    var isDepth:Bool = false
    var isPose:Bool = false
    var isGPS:Bool = false
    var isRTK:Bool = false
    var frameCount:Int = 0
    var rawMeshURL: URL?
    var scanFolder: URL?
    var totalSize: Int64?
    var cloudStatus:CloudButtonState?
}

