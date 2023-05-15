//
//  ConfigJsonManager.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/5/12.
//


import Foundation
import RealityKit
import ARKit
import SceneKit
import os

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
private let logger = Logger(subsystem: "com.graphopti.lidarScannerDemo",
                            category: "lidarScannerDemoDelegate")


struct ConfigJsonManager{
    
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
    
    init(uuid_ : UUID, owner_: String){
        uuid = uuid_;
        dataFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(uuid.uuidString)
        pointCloudName = "rawPointCloud.ply";
        meshModelName = "rawMesh.usd";
        jsonInfoName = "Info.json"
        infoJsonURL = dataFolder.appendingPathComponent(jsonInfoName);
        pointCloudURL = dataFolder.appendingPathComponent(pointCloudName);
        rawMeshURL = dataFolder.appendingPathComponent(meshModelName)
        totalFrame = 0;
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        name = formatter.string(from: Date())
        owners.append(owner_)
        createProjectFolder();
        createConfigFile();
    }
    
    mutating func setLidarMode(){
        mode = "lidar";
        isMeshModel = true;
        isPointCloud = false;
        isImageEnable = true;
        isTimeStampEnable = true;
        isIntrinsicEnable = true;
        isExtrinsicEnable = true;
        isDepthEnable = true;
        isConfidenceEnable = true;
        isGPSEnable = false;
        isRTKEnable = false;  
    }

    mutating func enableGPS(){
        isGPSEnable = true;
    }

    mutating func enableRTK(){
        isRTKEnable = true;
    }

    mutating func addOwner(newOwner: String){
        owners.append(newOwner);
    }
 
    mutating func updateFrameInfo(frame: ARFrame)
    {
        var jsonInfo = FrameJsonInfo(dataFolder_: dataFolder, arFrame_: frame);
        jsonInfo.updateJsonInfo();
        updateFrameCount();
    }
    
    mutating func updateFrameCount(){
        var existingJson: [String: Any] = [:]
        // Check if the info.json file exists
        if let jsonData = try? Data(contentsOf: infoJsonURL),
           let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
            existingJson = json
        }
        totalFrame = totalFrame+1;
        existingJson["frameCount"] = totalFrame;
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: existingJson, options: .prettyPrinted)
            try jsonData.write(to: infoJsonURL)
        } catch {
            logger.error("Failed to write JSON data: \(error.localizedDescription)")
        }
    }
    
    func createProjectFolder(){
        do {
            try FileManager.default.createDirectory(at: dataFolder, withIntermediateDirectories: true, attributes: nil)
            logger.info("CreateProjectFolder success at: \(dataFolder)")
        } catch let error {
            logger.error("Error creating directory: \(error.localizedDescription)")
        }
    }

    func createConfigFile(){
        do{
            try FileManager.default.createFile(atPath: infoJsonURL.path, contents: nil, attributes: nil)
            logger.info("CreateConfigFile success at: \(infoJsonURL)")
        } catch let error {
            logger.error("Error creating file: \(error.localizedDescription)")
        }
    }
    
    func getDataFoler()->URL{
        return dataFolder;
    }
    
    func getJsonInfoURL()->URL{
        return infoJsonURL;
    }
    
    func getRawMeshURL()->URL{
        return rawMeshURL;
    }
    
    func getPointCloudURL()->URL{
        return pointCloudURL;
    }
    
    func exportPointCloud(pointcloud : ARPointCloud) throws{
        let points = pointcloud.points;
        var plyContent = """
            ply
            format ascii 1.0
            element vertex \(points.count)
            property float x
            property float y
            property float z
            end_header
            """
        for point in points {
            plyContent += "\(point.x) \(point.y) \(point.z)\n"
        }
        do {
            let filePath = getPointCloudURL();
            try plyContent.write(to: filePath, atomically: true, encoding: .utf8)
            print("Point cloud saved successfully at \(filePath.path)")
        } catch {
            print("Error saving point cloud: \(error)")
        }
        
    }
    
    func exportRawMesh(asset: MDLAsset) throws {
        try asset.export(to: getRawMeshURL())
    }

func writeJsonInfo() {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    var jsonData: Data?
    do {
        let jsonDict: [String: Any] = [
            "uuid": uuid.uuidString,
            "frameCount": frames.count,
            "name": name,
            "owners": owners,
            "configs": [
                ["isImageEnable": isImageEnable],
                ["isTimeStampEnable": isTimeStampEnable],
                ["isIntrinsicEnable": isIntrinsicEnable],
                ["isExtrinsicEnable": isExtrinsicEnable],
                ["isDepthEnable": isDepthEnable],
                ["isConfidenceEnable": isConfidenceEnable],
                ["isGPSEnable": isGPSEnable],
                ["isRTKEnable": isRTKEnable],
                ["isMeshModel": isMeshModel],
                ["MeshModelName": meshModelName],
                ["isPointCloud": isPointCloud],
                ["PointCloudName": pointCloudName]
            ],
            "frames": []
        ]
        jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
    } catch let error {
        logger.error("Error encoding JSON: \(error.localizedDescription)")
    }
    if let jsonData = jsonData {
        do {
            try jsonData.write(to: infoJsonURL)
            logger.info("WriteJsonInfo success at: \(infoJsonURL)")
        } catch let error {
            logger.error("Error writing file: \(error.localizedDescription)")
        }
    }
}

}
