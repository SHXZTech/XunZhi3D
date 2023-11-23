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
    @Published private var model: LidarMeshModel
    @Published var isTooFast: Bool = false
    @Published var capturedFrameCount: Int = 0;
    private var cancellables = Set<AnyCancellable>()
     
    init(uuid: UUID) {
        model = LidarMeshModel(uuid_: uuid)
        model.$isTooFast
                   .receive(on: RunLoop.main)
                   .assign(to: \.isTooFast, on: self)
                   .store(in: &cancellables)
        model.$captureFrameCount
            .receive(on: RunLoop.main)
            .assign(to: \.capturedFrameCount, on: self)
            .store(in: &cancellables)
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

