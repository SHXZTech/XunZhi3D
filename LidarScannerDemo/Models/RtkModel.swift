//
//  RtkModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/24.
//

import Foundation

struct RtkModel {
    var deviceName: String = ""
    var electricity: String = ""
    var diffStatus: String = ""
    var diffDelay: String = ""
    var longitude: String = ""
    var latitude: String = ""
    var horizontalAccuracy: String = ""
    var verticalAccuracy: String = ""
    var satelliteCount: String = ""
    var fixStatus: Int = 0
    var height: Double = 0.0
    var list: [String] = []
}
