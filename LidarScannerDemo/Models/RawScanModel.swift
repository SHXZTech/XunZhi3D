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
    var estimatedProcessingTime:Int = 0;
    var destinationFolder: URL
    
    
    
    init(id_:UUID)
    {
        id = id_
        scanFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(id.uuidString)
        destinationFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(id.uuidString)
        loadFromJson()
        estimatedProcessingTime = frameCount*30;
    }
    
    mutating func loadFromJson() {
        let fileManager = FileManager.default
        let jsonURL = scanFolder.appendingPathComponent("info.json")
        //documentsDirectory.appendingPathComponent("\(id.uuidString)/info.json")
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
    
    func moveFileFromCacheToDestination() {
        let sourceFolder = scanFolder
        let destinationFolder = destinationFolder
        do {
            let fileManager = FileManager.default
            let contents = try fileManager.contentsOfDirectory(at: sourceFolder, includingPropertiesForKeys: nil)
            // Ensure the destination folder exists
            if !fileManager.fileExists(atPath: destinationFolder.path) {
                try fileManager.createDirectory(at: destinationFolder, withIntermediateDirectories: true, attributes: nil)
            }

            for item in contents {
                let destinationURL = destinationFolder.appendingPathComponent(item.lastPathComponent)

                do {
                    // Check if the source item exists before attempting to move
                    if fileManager.fileExists(atPath: item.path) {
                        if fileManager.fileExists(atPath: destinationURL.path) {
                            try fileManager.removeItem(at: destinationURL)
                        }
                        try fileManager.moveItem(at: item, to: destinationURL)
                    } else {
                        logger.error("Source item does not exist: \(item.lastPathComponent)")
                    }
                } catch {
                    logger.error("Error moving item \(item.lastPathComponent): \(error.localizedDescription)")
                }
            }
            logger.info("All files moved from \(sourceFolder) to \(destinationFolder)")
        } catch {
            logger.error("Error listing contents of \(sourceFolder) or creating destination folder: \(error.localizedDescription)")
        }
    }
}
