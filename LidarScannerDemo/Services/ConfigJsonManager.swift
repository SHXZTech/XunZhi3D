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
import ModelIO
import CoreGraphics



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
    var configs: [String: Any] = [:]
    var mode: String = "lidar"
    var rawMeshObjURL: URL
    var createDate: Date = Date()
    var dataDestinationFolder:URL
    var isRtkEnable = false
    var isGpsEnable = false
    var lat: String = ""
    var lon: String = ""
    var height: String = ""
    var vertical_accuracy: String = ""
    var horizontal_accuracy: String = ""
    
    init(uuid_ : UUID, owner_: String){
        uuid = uuid_;
        let baseDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        dataFolder = baseDirectory.appendingPathComponent(uuid.uuidString)
        //dataFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(uuid.uuidString)
        pointCloudName = "rawPointCloud.ply";
        meshModelName = "rawMesh.obj";
        jsonInfoName = "info.json"
        coverName = "cover.png"
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
        rawMeshObjURL = dataFolder.appendingPathComponent("mesh.obj")
        dataDestinationFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(uuid.uuidString)
    }
    
    
    mutating func setLidarModel(){
        mode = "lidar";
        isMeshModel = true;
        isPointCloud = false;
        isImageEnable = true;
        isTimeStampEnable = true;
        isIntrinsicEnable = true;
        isExtrinsicEnable = true;
        isDepthEnable = true;
        isConfidenceEnable = true;
    }
    
    mutating func addOwner(newOwner: String){
        owners.append(newOwner);
    }
    
    mutating func updateFrameInfo(frame: ARFrame){
        var jsonInfo = FrameJsonInfo(dataFolder_: dataFolder, arFrame_: frame);
        jsonInfo.saveFrameInfo();
        totalFrame = totalFrame+1;
    }
    
    
    mutating func updateCover() {
        do {
            // Get all image files in the dataFolder/images directory
            let imagesDirectoryURL = dataFolder.appendingPathComponent("images")
            let imageFiles = try FileManager.default.contentsOfDirectory(atPath: imagesDirectoryURL.path)
            // Select the first image file
            if let firstImageFile = imageFiles.first {
                let firstImageURL = imagesDirectoryURL.appendingPathComponent(firstImageFile)
                // Load the image
                if let image = UIImage(contentsOfFile: firstImageURL.path) {
                    // Resize the image to 720x720
                    let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 720, height: 720))
                    // Convert the resized image to data
                    if let imageData = resizedImage.pngData() {
                        // Write the data to cover.png
                        let coverURL = dataFolder.appendingPathComponent("cover.png")
                        if FileManager.default.fileExists(atPath: coverURL.path) {
                            try FileManager.default.removeItem(at: coverURL)
                        }
                        try imageData.write(to: coverURL)
                        //logger.info("Cover image updated successfully with \(firstImageFile)")
                    }
                }
            } else {
                logger.error("No images found in the images directory.")
            }
        } catch {
            logger.error("Failed to read images directory or update cover: \(error.localizedDescription)")
        }
    }

    // Helper function to resize an image
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Determine what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
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
        } catch {
            
        }
        
    }
    
    func exportRawMesh(asset: MDLAsset) throws {
        try asset.export(to: getRawMeshURL())
    }


    func exportRawMeshToObj(asset: MDLAsset) throws {
        let objects = asset.childObjects(of: MDLObject.self) as? [MDLObject] ?? []
        for object in objects {
            if let mesh = object as? MDLMesh {
                if let submeshes = mesh.submeshes as? [MDLSubmesh] {
                    for mdlSubmesh in submeshes {
                        let material = MDLMaterial(name: "customMaterial", scatteringFunction: MDLScatteringFunction())
                        // Define gray color using CGColor
                        let grayValue: CGFloat = 0.5  // Gray (midway between black and white)
                        let cgColor = CGColor(gray: grayValue, alpha: 1.0)
                        // Convert CGColor to float3 for MDLMaterialProperty
                        let colorVector = SIMD3<Float>(Float(cgColor.components![0]),
                                                       Float(cgColor.components![0]),
                                                       Float(cgColor.components![0]))
                        let colorProperty = MDLMaterialProperty(name: "baseColor",
                                                                semantic: .baseColor,
                                                                float3: colorVector)
                        // Assign the new material property to the submesh
                        material.setProperty(colorProperty)
                        mdlSubmesh.material = material
                    }
                }
            }
        }

        // Export the asset with the modified materials
        try asset.export(to: rawMeshObjURL)
    }

    mutating func enableRTK(){
        isRtkEnable = true
    }
    
    mutating func setRtkConfiInfo(rtk_data: RtkModel){
        lat = rtk_data.latitude;
        lon = rtk_data.longitude;
        height = String(rtk_data.height);
        horizontal_accuracy = rtk_data.horizontalAccuracy;
        vertical_accuracy = rtk_data.verticalAccuracy;
    }
    
    func writeJsonInfo() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        var jsonData: Data?
        let createDateTimestamp = createDate.timeIntervalSince1970
        do {
            let jsonDict: [String: Any] = [
                "uuid": uuid.uuidString,
                "frameCount": totalFrame,
                "name": name,
                "owners": owners,
                "configs": [
                    ["isImageEnable": isImageEnable],
                    ["isTimeStampEnable": isTimeStampEnable],
                    ["isIntrinsicEnable": isIntrinsicEnable],
                    ["isExtrinsicEnable": isExtrinsicEnable],
                    ["isDepthEnable": isDepthEnable],
                    ["isConfidenceEnable": isConfidenceEnable],
                    ["isMeshModel": isMeshModel],
                    ["MeshModelName": meshModelName],
                    ["isPointCloud": isPointCloud],
                    ["PointCloudName": pointCloudName],
                    ["coverName":coverName],
                    ["createDate": createDateTimestamp],
                    ["isGpsEnable": isGpsEnable],
                    ["isRtkEnable": isRtkEnable],
                    ["latitude": lat],
                    ["longitude": lon],
                    ["height": height],
                    ["horizontalAccuracy": horizontal_accuracy],
                    ["verticalAccuracy": vertical_accuracy]
                ]
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
