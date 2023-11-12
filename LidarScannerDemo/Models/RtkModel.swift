//
//  RtkModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/24.
//

import Foundation

struct RtkModel: Encodable {
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
    var signalStrength: UInt8 = 0
    var createTime: Date = Date()
    var timeStamp: Date = Date()

    private enum CodingKeys: String, CodingKey {
           case diffStatus, longitude, latitude
           case horizontalAccuracy, verticalAccuracy
           case fixStatus, height, createTime, timeStamp
       }

       func encode(to encoder: Encoder) throws {
           var container = encoder.container(keyedBy: CodingKeys.self)
           
           try container.encode(diffStatus, forKey: .diffStatus)
           try container.encode(longitude, forKey: .longitude)
           try container.encode(latitude, forKey: .latitude)
           try container.encode(horizontalAccuracy, forKey: .horizontalAccuracy)
           try container.encode(verticalAccuracy, forKey: .verticalAccuracy)
           try container.encode(fixStatus, forKey: .fixStatus)
           try container.encode(height, forKey: .height)
           try container.encode(createTime.timeIntervalSince1970, forKey: .createTime)
           try container.encode(timeStamp.timeIntervalSince1970, forKey: .timeStamp)
       }
}

