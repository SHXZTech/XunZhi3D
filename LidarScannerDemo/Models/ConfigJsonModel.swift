//
//  ConfigJsonModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/9.
//

import Foundation



struct ConfigJsonModel {
    var uuid: UUID
    var dataFolder: URL
    var infoJsonURL: URL
    var pointCloudURL: URL
    var rawMeshURL: URL
    var totalFrame: Int = 0
    var jsonInfoName: String
    var name: String = ""
    var owners: [String] = []
    var frames: [FrameJsonInfo] = []
    var isMeshModel: Bool = false
    var meshModelName: String = ""
    var isPointCloud: Bool = false
    var pointCloudName: String = ""
    var isImageEnable: Bool = false
    var isTimeStampEnable: Bool = false
    var isIntrinsicEnable: Bool = false
    var isExtrinsicEnable: Bool = false
    var isDepthEnable: Bool = false
    var isConfidenceEnable: Bool = false
    var isGPSEnable: Bool = false
    var isRTKEnable: Bool = false
    var configs: [String: Any] = [:]
    var mode: String = "lidar"
}
