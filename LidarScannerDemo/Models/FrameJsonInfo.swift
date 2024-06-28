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
    var intrinsic: simd_float3x3
    var extrinsic: simd_float4x4
    var ImageName: String = ""
    var depthImageName: String = ""
    var confidenceMapName: String = ""
    var GPS: CLLocation?
    var RTK: CLLocation?
    var timeStampGlobal: Date = Date()
    var imageFolder:URL
    var depthFolder:URL
    var confidenceFolder:URL
    var camerasFolder:URL
    
    
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
        imageFolder = dataFolder_.appendingPathComponent("images")
        depthFolder = dataFolder_.appendingPathComponent("depth")
        confidenceFolder = dataFolder_.appendingPathComponent("confidence")
        camerasFolder = dataFolder_.appendingPathComponent("cameras")
    }
    
    /*
     Description: Update json info with new arframe
     Input: None
     Output: Bool, true if success
     Author: Thomas (thomas@graphopti.com)
     Date: 2021/5/15
     Status: NeedTest
     */
    mutating func saveFrameInfo()-> Bool{
        writeImages();
        saveCameraInfo();
        return true;
    }
    
    /**
     Description: Save camera information to a JSON file. The function generates a JSON object with camera intrinsic and extrinsic parameters, image size, and other relevant data, and writes it to a file in the cameras folder.
     Author: [Your Name]
     Date: [Current Date]
     Status: [Current Status (e.g., In Development, Need Test, etc.)]
     */
    mutating func saveCameraInfo() {
        // Generate the file name using the timestamp
        do {
            try FileManager.default.createDirectory(at: camerasFolder, withIntermediateDirectories: true, attributes: nil)
        } catch {
            logger.error("Failed to create directory: \(error.localizedDescription)")
            return
        }
        let timeStampSince1970 = timeStampGlobal.timeIntervalSince1970
        let fileName = String(format: "%.15f", timeStampSince1970) + ".json"
        let fileURL = camerasFolder.appendingPathComponent(fileName)
        // Create the JSON content
        let imageSize = getFrameSize()
        let cameraInfo: [String: Any] = [
            "timestamp": timeStamp,
            "globaltimestamp": timeStampSince1970,
            "height": Int(imageSize.height),
            "width": Int(imageSize.width),
            "cx": intrinsic[2][0],
            "cy": intrinsic[2][1],
            "fx": intrinsic[0][0],
            "fy": intrinsic[1][1],
            "neighbors": [], //TODO use other algorithm to decide the neighbors.
            "t_00": extrinsic[0][0],
            "t_01": extrinsic[1][0],
            "t_02": extrinsic[2][0],
            "t_03": extrinsic[3][0],
            "t_10": extrinsic[0][1],
            "t_11": extrinsic[1][1],
            "t_12": extrinsic[2][1],
            "t_13": extrinsic[3][1],
            "t_20": extrinsic[0][2],
            "t_21": extrinsic[1][2],
            "t_22": extrinsic[2][2],
            "t_23": extrinsic[3][2]
        ]
    
        // Write the JSON content to the file
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: cameraInfo, options: .prettyPrinted)
            try jsonData.write(to: fileURL)
        } catch {
        }
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
        let timeStampSince1970 = timeStampGlobal.timeIntervalSince1970
        let fileName = String(format: "%.15f", timeStampSince1970)
        if let jpegData = arFrame.capturedjpegData(){
            ImageName = saveJpgData(jpegData: jpegData, fileFolder: imageFolder, timeStamp: fileName, type: "")
        }
        if(arFrame.sceneDepth != nil) || (arFrame.smoothedSceneDepth != nil) {
            if let depthImage = arFrame.lidarDepthData()
            {
                depthImageName = savePngData(pngData: depthImage, fileFolder: depthFolder, timeStamp: fileName, type: "");
            }
            if let confidenceImage = arFrame.lidarConfidenceData() {
                confidenceMapName = savePngData(pngData: confidenceImage, fileFolder: confidenceFolder, timeStamp: fileName, type: "")
            }
        }
    }
    
    mutating func getFrameSize() -> CGSize {
        if let jpegData = arFrame.capturedjpegData() {
            // Initialize a UIImage with the jpegData
            if let image = UIImage(data: jpegData) {
                // Get the size of the image
                let size = image.size
                return size
            }
        }
        return CGSize(width: 0.0, height: 0.0)
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
