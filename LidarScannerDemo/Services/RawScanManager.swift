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
 //   var uuid:UUID
//    var isExist:Bool = false
//    var isRawMeshExist:Bool = false
//    var isDepth:Bool = false
//    var isPose:Bool = false
//    var isGPS:Bool = false
//    var isRTK:Bool = false
//    var frameCount:Int = 0
//    var rawMeshURL: URL?
    
    var raw_scan_model: RawScanModel
    
    
    init(uuid:UUID){
        self.raw_scan_model = RawScanModel(id_:uuid)
        //TODO modift the data into scan_model
 //       raw_scan_model.id = uuid
//        raw_scan_model.isExist = self.isExistCheck()
//        raw_scan_model.isRawMeshExist = self.isRawMeshExistCheck()
//        if(raw_scan_model.isRawMeshExist){
//            raw_scan_model.rawMeshURL = self.getRawMeshURL()
//        }
    }
    
    func isRawMeshExist() -> Bool{
        return raw_scan_model.isRawMeshExist
    }
    
    func getRawMeshURL()-> URL{
        return raw_scan_model.rawMeshURL ?? raw_scan_model.getRawMeshURL()
    }
}
