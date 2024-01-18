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
    
    var raw_scan_model: RawScanModel
    
    
    init(uuid:UUID){
        self.raw_scan_model = RawScanModel(id_:uuid)
    }
    
    func deleteProjectFolder(){
        self.raw_scan_model.deleteScanFolder()
    }
    
    func isRawMeshExist() -> Bool{
        return raw_scan_model.isRawMeshExist
    }
    
    func getRawObjURL()-> URL{
       return raw_scan_model.getRawObjURL()
    }
    
    func getRawMeshURL()-> URL{
        return raw_scan_model.rawMeshURL ?? raw_scan_model.getRawMeshURL()
    }
    
    func moveScanFromCacheToDist(){
        raw_scan_model.moveFileFromCacheToDestination()
    }
}
