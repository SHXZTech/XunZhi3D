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
    var coverName: String = ""
    var coverURL: URL
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
    
    // adding
    var createDate: Date = Date()
    
    init(uuid_ : UUID, owner_: String){
        uuid = uuid_;
        dataFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(uuid.uuidString)
        pointCloudName = "rawPointCloud.ply";
        meshModelName = "rawMesh.usd";
        jsonInfoName = "info.json"
        coverName = "cover.jpeg"
        infoJsonURL = dataFolder.appendingPathComponent(jsonInfoName);
        pointCloudURL = dataFolder.appendingPathComponent(pointCloudName);
        rawMeshURL = dataFolder.appendingPathComponent(meshModelName)
        coverURL = dataFolder.appendingPathComponent(coverName)
        totalFrame = 0;
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        name = formatter.string(from: Date())
        owners.append(owner_)
        createDate = Date()
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
    
    mutating func updateFrameInfo(frame: ARFrame, rtkModel: RtkModel = RtkModel()){
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
    
    mutating func updateCover() {
        print("start updating cover..")
        // Read and parse the info.json file to find the first image name with the "RGB_" prefix
        do {
            let jsonData = try Data(contentsOf: infoJsonURL)
            if let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let framesArray = jsonDict["frames"] as? [[String: Any]] {
                // Find the first frame that contains an image name starting with "RGB_"
                if let firstRGBFrame = framesArray.first(where: { frame in
                    guard let imageName = frame["imageName"] as? String else { return false }
                    print("start updating cover.. 1 ")
                    return imageName.hasPrefix("RGB_")
                }) {
                    let rgbImageName = firstRGBFrame["imageName"] as! String
                    let rgbImageURL = dataFolder.appendingPathComponent(rgbImageName)
                    // Copy the found image to cover.jpeg
                    if FileManager.default.fileExists(atPath: coverURL.path) {
                        try FileManager.default.removeItem(at: coverURL)
                    }
                    print("try to cp ", rgbImageURL.path, " to ", coverURL.path)
                    try FileManager.default.copyItem(at: rgbImageURL, to: coverURL)
                    logger.info("Cover image updated successfully with \(rgbImageName)")
                } else {
                    logger.error("No RGB image found in frames.")
                }
            } else {
                logger.error("info.json format is incorrect or 'frames' key is missing.")
            }
        } catch {
            logger.error("Failed to read or parse info.json: \(error.localizedDescription)")
        }
    }
    
    
    func createProjectFolder(){
        print("create: project folder")
        do {
            try FileManager.default.createDirectory(at: dataFolder, withIntermediateDirectories: true, attributes: nil)
            logger.info("CreateProjectFolder success at: \(dataFolder)")
        } catch let error {
            logger.error("Error creating directory: \(error.localizedDescription)")
        }
    }
    
    func createConfigFile(){
        print("create config file")
        do{
            try FileManager.default.createFile(atPath: infoJsonURL.path, contents: nil, attributes: nil)
            logger.info("CreateConfigFile success at: \(infoJsonURL)")
        } catch let error {
            logger.error("Error creating file: \(error.localizedDescription)")
        }
    }
    
    func deleteProjecFolder(){
        do {
            try FileManager.default.removeItem(at: dataFolder)
            logger.info("Project folder deleted successfully at: \(dataFolder)")
        } catch {
            logger.error("Error deleting project folder: \(error.localizedDescription)")
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
            end_header\n
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
        let createDateTimestamp = createDate.timeIntervalSince1970
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
                    ["PointCloudName": pointCloudName],
                    ["coverName":coverName],
                    ["createDate": createDateTimestamp]
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
