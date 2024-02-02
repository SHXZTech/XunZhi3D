//
//  RawScanModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/9.
//

import Foundation
import os

private let logger = Logger(subsystem: "com.graphopti.lidarScannerDemo",
                            category: "lidarScannerDemoDelegate")



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
    var scanFolder: URL
    var zipFileURL: URL?
    var estimatedProcessingTime:Int = 0;
    var uploadingProgress: Float = 0.0
    var downloadingProgress: Float = 0.0
    var cloudStatus:CloudButtonState?
    
    
    
    init(id_:UUID)
    {
        id = id_
        scanFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(id.uuidString)
        loadFromJson()
        estimatedProcessingTime = frameCount*3 + 120;
        zipFileURL = scanFolder.appendingPathComponent(id.uuidString+".zip")
    }
    
    mutating func loadFromJson() {
        let fileManager = FileManager.default
        let jsonURL = scanFolder.appendingPathComponent("info.json")
        do {
            let jsonData = try Data(contentsOf: jsonURL)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            if let jsonDict = jsonObject as? [String: Any] {
                self.isExist = self.isExistCheck()
                let rawMeshName = "mesh.obj"
                let rawMeshPath = scanFolder.appendingPathComponent(rawMeshName).path
                self.isRawMeshExist = fileManager.fileExists(atPath: rawMeshPath)
                if self.isRawMeshExist {
                    self.rawMeshURL = URL(fileURLWithPath: rawMeshPath)
                }
                self.isDepth = (jsonDict["configs"] as? [[String: Any]])?.contains(where: { $0["isDepthEnable"] as? Bool == true }) ?? false
                self.isPose = (jsonDict["configs"] as? [[String: Any]])?.contains(where: { ($0["isIntrinsicEnable"] as? Bool == true) || ($0["isExtrinsicEnable"] as? Bool == true) }) ?? false
                self.isGPS = (jsonDict["configs"] as? [[String: Any]])?.contains(where: { $0["isGPSEnable"] as? Bool == true }) ?? false
                self.isRTK = (jsonDict["configs"] as? [[String: Any]])?.contains(where: { $0["isRTKEnable"] as? Bool == true }) ?? false
                self.frameCount = (jsonDict["frameCount"] as? Int) ?? 0
            }
        } catch {
        }
    }
    
    func deleteScanFolder() {
        let fileManager = FileManager.default
        do {
            if fileManager.fileExists(atPath: scanFolder.path) {
                try fileManager.removeItem(at: scanFolder)
                logger.info("Project folder deleted successfully at: \(scanFolder.path)")
            } else {
                logger.warning("Project folder does not exist at the path: \(scanFolder.path).")
            }
        } catch {
            logger.error("Error deleting project folder: \(error.localizedDescription)")
        }
    }
    
    
    func isExistCheck() -> Bool {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: scanFolder.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    func getRawMeshURL() -> URL {
        let rawMeshURL = scanFolder.appendingPathComponent("rawMesh.usd")
        return rawMeshURL
    }
    
    func getRawObjURL() -> URL{
        let rawMeshURL = scanFolder.appendingPathComponent("mesh.obj")
        return rawMeshURL
    }
    
}
