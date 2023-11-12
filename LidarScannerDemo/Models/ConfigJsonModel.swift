//
//  ConfigJsonModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/9.
//

import Foundation
/*
 Description: Save scanning data to local with this struct.
 Example format:
 {
   "uuid": 1232141234,
   "frameCount": 10,
   "name":"2021-01-03_10:43:00",
   "owners": [{"owner":"local"},{"owner":"34234"}],
   "configs":[
     {"isImageEnable": true},
     {"isTimeStampEnable": true},
     {"isIntrinsicEnable": true},
     {"isExtrinsicEnable": true},
     {"isDepthEnable": true},
     {"isConfidenceEnable": true},
     {"isGPSEnable": false},
     {"isRTKEnable": false},
     {"isMeshModel": true},
     {"MeshModelName": "rawMesh.usd"},
     {"isPointCloud": false},
     {"PointCloudName": "rawPointCloud.ply"}
   ],
   "frames":[{
     "ImageName" : "94949.jpg",
     "TimeStamp": 32342342.3234,
     "Intrinsic": [
             [[3121.992919921875,0,0],
              [0,3121.992919921875,0],
              [2031.5745849609375,1509.04443359375,1]
             ]],
     "Extrinsic": [[[1,0,0,0],
               [0,1,0,0],
               [0,0,1,0],
               [0,0,0,1]]],
     "DepthImageName": "abcd.jpeg",
     "ConfidenceMapName":"abcd.TIF",
     "GPS":{"lat": 121, "lon" :31.0},
     "RTK":{"lat": 121, "lon" :31.0}
   },{
     "ImageName" : "94949.jpg",
     "TimeStamp": 32342342.3234,
     "Intrinsic": [
             [[3121.992919921875,0,0],
              [0,3121.992919921875,0],
              [2031.5745849609375,1509.04443359375,1]
             ]],
     "Extrinsic": [[[1,0,0,0],
               [0,1,0,0],
               [0,0,1,0],
               [0,0,0,1]]],
     "DepthImageName": "abcd.jpeg",
     "ConfidenceMapName":"abcd.TIF",
     "GPS":{"lat": 121, "lon" :31.0},
     "RTK":{"lat": 121, "lon" :31.0}
   }]
 }
 
 */


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
