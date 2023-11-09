//
//  RawScanManager.swift
//  SwitchCameraTutorial
//
//  Created by Tao Hu on 2023/4/21.
//

import Foundation
import ARKit
import SceneKit

struct RawScanManager{
    var uuid:UUID
    var isExist:Bool = false
    var isRawMeshExist:Bool = false
    var isDepth:Bool = false
    var isPose:Bool = false
    var isGPS:Bool = false
    var isRTK:Bool = false
    var frameCount:Int = 0
    var rawMeshURL: URL?
    
    var raw_scan_model: RawScanModel
    
    init(uuid:UUID){
        self.raw_scan_model = RawScanModel(id:uuid)
        //TODO modift the data into scan_model
        self.uuid = uuid
        self.isExist = self.isExistCheck()
        self.isRawMeshExist = self.isRawMeshExistCheck()
        if(isRawMeshExist)
        {self.rawMeshURL = self.getRawMeshURL()}
        
    }
    
   mutating func isExistCheck() -> Bool {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderURL = documentsDirectory.appendingPathComponent(uuid.uuidString)
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: folderURL.path, isDirectory: &isDirectory)
        self.isExist = exists && isDirectory.boolValue
        return exists && isDirectory.boolValue
    }
    
    
    mutating func isRawMeshExistCheck() -> Bool {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderURL = documentsDirectory.appendingPathComponent(uuid.uuidString)
        let fileURL = folderURL.appendingPathComponent("rawMesh.usd")
        self.isRawMeshExist =  fileManager.fileExists(atPath: fileURL.path)
        return fileManager.fileExists(atPath: fileURL.path)
    }

    
    func getRawMeshURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let rawMeshURL = documentsDirectory.appendingPathComponent(uuid.uuidString).appendingPathComponent("rawMesh.usd")
        return rawMeshURL
    }
    
}
