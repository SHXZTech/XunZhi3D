//
//  RawScanModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/9.
//

import Foundation

struct RawScanModel: Identifiable {
    var id:UUID
    var isExist:Bool = false
    var isRawMeshExist:Bool = false
    var isDepth:Bool = false
    var isPose:Bool = false
    var isGPS:Bool = false
    var isRTK:Bool = false
    var frameCount:Int = 0
    var rawMeshURL: URL?
}
