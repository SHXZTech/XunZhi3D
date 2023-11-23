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
import SwiftUI
import Combine

class LidarMeshViewModel: ObservableObject {
    //@Published private var model : LidarMeshModel = LidarMeshModel(uuid_: uuid)
    @Published private var model: LidarMeshModel
    @Published var isTooFast: Bool = false
    private var cancellables = Set<AnyCancellable>()
     
    init(uuid: UUID) {
        //model = LidarMeshModel(uuid_: uuid, tooFastFlag: tooFastCheck)
        model = LidarMeshModel(uuid_: uuid)
        
        // Observe changes to isTooFast in the model
        model.$isTooFast
                   .receive(on: RunLoop.main)
                   .assign(to: \.isTooFast, on: self)
                   .store(in: &cancellables)
    }
    
    deinit {
        
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

