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
    private var isRawMeshExist:Bool = false
    private var isDepth:Bool = false
    private var isPose:Bool = false
    private var isGPS:Bool = false
    private var isRTK:Bool = false
    
    private var frameCount:Int = 0
    
    
    
    init(uuid:UUID){
        self.uuid = uuid
        self.isExist = self.isExistCheck()
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
        let fileURL = folderURL.appendingPathComponent("RawMesh.usd")
        self.isRawMeshExist =  fileManager.fileExists(atPath: fileURL.path)
        return fileManager.fileExists(atPath: fileURL.path)
    }

    
}
