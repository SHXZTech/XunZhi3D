//
//  ARModel.swift
//  SwitchCameraTutorial
//
//  Created by Cole Dennis on 9/18/22.
//

import Foundation
import RealityKit
import ARKit

struct LidarMeshModel {
    private(set) var sceneView : ARSCNView
    
    init() {
        sceneView = ARSCNView(frame: .zero)
        //sceneView.delegate = context.coordinator
        let config = ARWorldTrackingConfiguration()
        sceneView.session.run(config)
        sceneView.addCoaching()
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints, SCNDebugOptions.showCameras]
    }
    
    func startScan(){
        let config = ARWorldTrackingConfiguration()
        config.environmentTexturing = .automatic
        config.sceneReconstruction = .mesh
        config.worldAlignment = .gravity
        if type(of: config).supportsFrameSemantics(.sceneDepth) {
            config.frameSemantics = .sceneDepth
            print("startScan starting we are here")
        }
        sceneView.session.run(config, options: [.removeExistingAnchors, .resetSceneReconstruction, .resetTracking])
    }
    
    func pauseScan(){
        sceneView.session.pause()
    }
    
    func saveScan(uuid:UUID)-> Bool{
        guard let camera = sceneView.session.currentFrame?.camera else {
            print("guard camera fail")
            return false}
        if let meshAnchors = sceneView.session.currentFrame?.anchors.compactMap({ $0 as? ARMeshAnchor }),
           let asset = convertToAsset(meshAnchors: meshAnchors) {
            do {
                let url = try exportAsset(asset: asset, uuid: uuid)
                print("save successful at", url.path)
                return true
            } catch {
                return false
            }
        }
        return true
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    func convertToAsset(meshAnchors: [ARMeshAnchor]) -> MDLAsset? {
        guard let camera = sceneView.session.currentFrame?.camera else {return nil}
        guard let device = MTLCreateSystemDefaultDevice() else {return nil}
        let asset = MDLAsset()
        for anchor in meshAnchors {
            let mdlMesh = anchor.geometry.toMDLMesh(device: device, camera: camera, modelMatrix: anchor.transform)
            asset.add(mdlMesh)
        }
        return asset
    }
    
    func exportAsset(asset: MDLAsset, uuid: UUID) throws -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(uuid.uuidString).appendingPathComponent("rawMesh.usd")
        try asset.export(to: fileURL)
        print("export path:", fileURL.path)
        return fileURL
    }
    
    
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        let parent : LidarMeshModel
        
        init(_ parent: LidarMeshModel) {
            self.parent = parent
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let meshAnchor = anchor as? ARMeshAnchor else { return }
            node.geometry = SCNGeometry.makeFromMeshAnchor(meshAnchor)
        }
    }
    
    
    
    
}

