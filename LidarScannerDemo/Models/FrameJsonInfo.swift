//
//  FrameJsonInfo.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/5/10.
//

import Foundation
import RealityKit
import ARKit
import SceneKit
import os





private let logger = Logger(subsystem: "com.graphopti.lidarScannerDemo",
                            category: "lidarScannerDemoDelegate")

/*
 Description: Save arframe data to local with this struct.
 Details:
         Example format:
         {
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
         }
 Author: Thomas( thomas@graphopti.com)
 Date: 2021/5/15
 */
struct FrameJsonInfo{
    var dataFolder: URL
    var infoJsonURL: URL
    var arFrame: ARFrame
    
    var timeStamp: TimeInterval = 0.0
    var intrinsic: simd_float3x3?
    var extrinsic: simd_float4x4?
    var ImageName: String = ""
    var depthImageName: String = ""
    var confidenceMapName: String = ""
    var GPS: CLLocation?
    var RTK: CLLocation?
    var timeStampGlobal: Date = Date()
    
    /*
     Description: Init the struct with data folder, info json url and arframe. AutoSave images to local;
     Author: Thomas (thomas@graphopti.com)
     Date: 2021/5/15
     */
    init(dataFolder_: URL, arFrame_: ARFrame){
        dataFolder = dataFolder_;
        infoJsonURL = dataFolder_.appendingPathComponent("info.json");
        arFrame = arFrame_;
        timeStamp = arFrame.timestamp
        intrinsic = arFrame.camera.intrinsics
        extrinsic = arFrame.camera.transform
        timeStampGlobal = Date()
    }
    
    /*
    Description: Update json info with new arframe
    Input: None
    Output: Bool, true if success
    Author: Thomas (thomas@graphopti.com)
    Date: 2021/5/15
    Status: NeedTest
    */
    mutating func updateJsonInfo()-> Bool{
        writeImages();
        wirteJsonContent();
        return true;
    }
    



    
    /**
     Description: Write json content to Info.json
     Input: None
     Output: Bool, true if success
     Author: Thomas (thomas@graphopti.com)
     Date: 2021/5/15
     Status: NeedTest
     */
    func wirteJsonContent()->Bool{
        let jsonContent = createJsonContent();
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonContent, options: .prettyPrinted)
            try jsonData.write(to: infoJsonURL)
        } catch {
            logger.error("Failed to write JSON data: \(error.localizedDescription)")
        }
        return true;
    }
    



    /**
        Description: create json content with current arframe
        Input: None
        Output: [String:Any], json content
        Author: Thomas (thomas@graphopti.com)
        Date: 2021/5/15
        Status: NeedTest
    */
    func createJsonContent() ->[String:Any]{
        var existingJson: [String: Any] = [:]
        // Check if the info.json file exists
        if let jsonData = try? Data(contentsOf: infoJsonURL),
           let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
            existingJson = json
        }
        // Fetch existing frames array from info.json if it exists
        var framesArray: [[String: Any]] = existingJson["frames"] as? [[String: Any]] ?? []
        // Create the new frame info
        let jsonContent: [String: Any] = [
            "imageName": ImageName,
            "timeStamp": timeStamp,
            "intrinsic": intrinsic?.arrayRepresentation() ?? [],
            "extrinsic": extrinsic?.arrayRepresentation() ?? [],
            "depthImageName": depthImageName,
            "confidenceMapName": confidenceMapName,
            "timeStampGlobal" : timeStampGlobal.timeIntervalSince1970,
            "GPS": ["latitude": GPS?.coordinate.latitude ?? 0, "longitude": GPS?.coordinate.longitude ?? 0, "accuracy": GPS?.horizontalAccuracy],
            "RTK": ["latitude": GPS?.coordinate.latitude ?? 0, "longitude": GPS?.coordinate.longitude ?? 0, "accuracy": GPS?.horizontalAccuracy],
        ]
        
        // Append the new frame info to the frames array
        framesArray.append(jsonContent)
        // Update the frames array in the existing JSON
        existingJson["frames"] = framesArray;
        
        
        return existingJson;
    }

    
    
    /**
     Description: Save RGB/Depth/Confidence images to local
     Input: None
     Output: None
     Author: Thomas (thomas@graphopti.com)
     Date: 2021/5/15
     Status: NeedTest
     */
    mutating func writeImages(){
        if let jpegData = arFrame.capturedjpegData(){
            ImageName = saveJpegData(jpegData: jpegData, fileFolder: dataFolder, timeStamp: timeStamp, type: "RGB")
        }
        if(arFrame.sceneDepth != nil) || (arFrame.smoothedSceneDepth != nil) {
            if let depthImage = arFrame.lidarDepthData()
            {
                depthImageName = saveTiffData(tiffData: depthImage, fileFolder: dataFolder, timeStamp: timeStamp, type: "Depth");
            }
            if let confidenceImage = arFrame.lidarConfidenceData() {
                confidenceMapName = saveTiffData(tiffData: confidenceImage, fileFolder: dataFolder, timeStamp: timeStamp, type: "Confidence")
            }
        }
    }
}



/**
    Description: present the simd_float3x3 as josn format array
    Author: thomas (thomas@graphopti.com)
    Date: 2021/5/15
    Status: NeedTest
*/
extension simd_float3x3 {
    func arrayRepresentation() -> [[Float]] {
        let array: [[Float]] = [
            [self.columns.0.x, self.columns.0.y, self.columns.0.z],
            [self.columns.1.x, self.columns.1.y, self.columns.1.z],
            [self.columns.2.x, self.columns.2.y, self.columns.2.z]
        ]
        return array
    }
}

/**
    Description: present the simd_float4x4 as josn format array
    Author: thomas (thoams@grpahopti.com)
    Date: 2021/5/15
    Status: NeedTest
*/
extension simd_float4x4 {
    func arrayRepresentation() -> [[Float]] {
        let array: [[Float]] = [
            [self.columns.0.x, self.columns.0.y, self.columns.0.z, self.columns.0.w],
            [self.columns.1.x, self.columns.1.y, self.columns.1.z, self.columns.1.w],
            [self.columns.2.x, self.columns.2.y, self.columns.2.z, self.columns.2.w],
            [self.columns.3.x, self.columns.3.y, self.columns.3.z, self.columns.3.w]
        ]
        return array
    }
}
