//
//  ARViewModel.swift
//  SwitchCameraTutorial
//
//  Created by Cole Dennis on 9/18/22.
//

import Foundation
import RealityKit
import SceneKit
import ARKit


class LidarMeshViewModel: ObservableObject {
    //@Published private var model : LidarMeshModel = LidarMeshModel(uuid_: uuid)
    @Published private var model: LidarMeshModel
    
    init(uuid: UUID) {
           model = LidarMeshModel(uuid_: uuid)
       }
    
    deinit {
        print("deinit LidarMeshViewModel: ObservableObject")
           // Stop any work and release resources
       }
    
    var sceneView : ARSCNView {
        model.sceneView
    }
    
    func startScan(){
        model.startScan()
    }
    
    func pauseScan(){
        model.pauseScan()
    }
    
    func saveScan(uuid: UUID)-> Bool{
        return model.saveScan(uuid: uuid)
    }
    
    func dropScan(){
        model.dropScan()
    }
    
}

