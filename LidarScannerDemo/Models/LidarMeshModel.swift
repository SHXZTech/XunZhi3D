//
//  ARModel.swift
//  LidarScannerDemoTests
//
//  Created by Cole Dennis on 9/18/22.
//

import Foundation
import RealityKit
import ARKit
import SceneKit
import os
import SwiftUI

private let logger = Logger(subsystem: "com.graphopti.lidarScannerDemo",
                            category: "lidarScannerDemoDelegate")

class LidarMeshModel:NSObject, ARSessionDelegate {
    private(set) var sceneView : ARSCNView // The ARSCNView used to display the scene.
    
    var uuid:UUID // The UUID of the scan.
    
    @Published var isTooFast:Bool = false
    @Published var captureFrameCount:Int = 0
    
    private var status:String? // The current status of the scan ("ready", "scanning", or "finished").
    
    enum CaptureMode {
        /// The user has selected manual capture mode, which captures one
        /// image per button press.
        case lidar
        
        case manual
        
        case auto
        
    }
    
    private var mode:String = "Auto" // "auto_lidar, auto_camera, manual,"
    private var overlapThreshold:Int=90 // The overlap between the current frame and the previous frame.
    
    private var distanceThreshold:Int=10// The distance between the device and the object being scanned.
    
    private var angleThreshold:Int=10 // The angle of the device relative to the object being scanned.
    
    private var speedThreshold:Float = 0.5 // over speed threshold, present warnnign
    
    private var isLidarEnable:Bool=false // Whether LiDAR is enabled.
    
    private var isDepthEnable:Bool=false // Whether depth is enabled.
    
    private var isGPSEnable:Bool=false // Whether GPS is enabled.
    
    private var isRTKEnable:Bool=false // Whether RTK is enabled.
    
    private var previousFrameTimeStamp:TimeInterval = 0.0
    private var previousFramePose:simd_float4x4 =  simd_float4x4([
        simd_float4(1, 0, 0, 0),
        simd_float4(0, 1, 0, 0),
        simd_float4(0, 0, 1, 0),
        simd_float4(0, 0, 0, 1)
    ])// The pose of the previous frame.
    private var previousSavedFramePose:simd_float4x4=simd_float4x4([
        simd_float4(1, 0, 0, 0),
        simd_float4(0, 1, 0, 0),
        simd_float4(0, 0, 1, 0),
        simd_float4(0, 0, 0, 1)
    ])// The pose of the previous saved frame.
    
    enum ThresholdError: Error {
        case invalidDistanceThreshold
        case invalidAngleThrehold
    }
    
    private var configJsonManager: ConfigJsonManager;
    
    /**
     Init the class, configure and run the sceneView
     */
    init(uuid_: UUID) {
        status = "ready"
        sceneView = ARSCNView(frame: .zero)
        uuid = uuid_
        configJsonManager = ConfigJsonManager(uuid_: uuid, owner_: "local")
        configJsonManager.setLidarModel();
        super.init()
        let config = ARWorldTrackingConfiguration()
        sceneView.session.delegate = self
        sceneView.session.run(config)
        sceneView.addCoaching()
#if DEBUG
        //sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints, SCNDebugOptions.showCameras]
#endif
        setAngleThreshold(threshold: 10) // set to 10cm
        setDistanceThreshold(threshold: 10) // set to 10 degree
        isTooFast = false
        captureFrameCount = 0;
    }
    
    /**
     Inherite from ARSessionDelegate, this function used to save scan data. When a arFrame updates, it toggles this function.
     */
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let currentTransform = frame.camera.transform
        let currentFrameTimeStamp = frame.timestamp
        let currentFramePose = frame.camera.transform
        if(status == "scanning" && tooFastCheck(currentFramePose: currentFramePose, currentTimeStamp: currentFrameTimeStamp, previousFramePose: previousFramePose, previousTimeStamp: previousFrameTimeStamp)){
            isTooFast = true;
        }
        else{
            isTooFast = false;
        }
        previousFrameTimeStamp = frame.timestamp
        previousFramePose = frame.camera.transform
        if(status == "scanning" && newFrameCheck(currentFramePose: currentTransform, previousFramePose: previousSavedFramePose))
        {
            previousSavedFramePose = currentTransform
            configJsonManager.updateFrameInfo(frame: frame)
            captureFrameCount+=1
        }
    }
    
    /**
     Check whether the new frame is acceptable, it checks whether the overlap/distance/angle between frames meet the threholds
     
     @input: previousFrame pose and timestamp, newFrame pose and timestamp
     @output: Bool; true - the new frame meets the conditions, false - the new frame does not meet the conditions
     */
    func newFrameCheck(currentFramePose: simd_float4x4, previousFramePose: simd_float4x4)-> Bool{
        // Overlap check
        // Distance & angle check
        let distance = Int(calculatePoseDistance(currentFramePose: currentFramePose, previousFramePose: previousFramePose)*100);
        //trans distance in cm
        let angleDiff = Int(calculatePoseAngle(currentFramePose: currentFramePose, previousFramePose: previousFramePose)/Float.pi * 180);
        if(distance >= distanceThreshold || angleDiff >= angleThreshold){
            return true
        }
        return false
    }
    
    /**
     Check whether the camera movement is too fast?
     
     @input: previousFrame pose and timestamp, newFrame pose and timestamp
     @output: Bool; true - the new frame moves too fast, false - the new frame move smoothly
     */
    func tooFastCheck(currentFramePose: simd_float4x4, currentTimeStamp: TimeInterval, previousFramePose: simd_float4x4, previousTimeStamp: TimeInterval)->Bool{
        let speed = calculateMovementSpeed(currentFramePose: currentFramePose, currentTimeStamp: currentTimeStamp, previousFramePose: previousFramePose, previousTimeStamp: previousTimeStamp)
        if(speed >= speedThreshold){
            return true;
        }
        return false;
    }
    
    //testpass
    func calculatePoseDistance(currentFramePose: simd_float4x4, previousFramePose: simd_float4x4)-> Float{
        let currentPoseTrans = simd_float3(currentFramePose.columns.3.x, currentFramePose.columns.3.y, currentFramePose.columns.3.z)
        let previousPoseTrans = simd_float3(previousFramePose.columns.3.x, previousFramePose.columns.3.y, previousFramePose.columns.3.z)
        let distance = abs(simd_distance(currentPoseTrans, previousPoseTrans))
        return distance
    }
    //testpass
    func calculatePoseAngle(currentFramePose: simd_float4x4, previousFramePose: simd_float4x4)-> Float{
        let previousFrameQuaternion = simd_quatf(previousFramePose).normalized
        let currentFrameQuaternion = simd_quatf(currentFramePose).normalized
        let quaternionProduct = simd_mul(currentFrameQuaternion, previousFrameQuaternion.inverse)
        var angle = quaternionProduct.angle
        angle = abs(angle.truncatingRemainder(dividingBy: 2 * Float.pi)) // make sure the angle be less to 0-pi
        return angle
    }
    
    func calculateMovementSpeed(currentFramePose: simd_float4x4, currentTimeStamp: TimeInterval, previousFramePose: simd_float4x4, previousTimeStamp: TimeInterval)->Float{
        let timeDiff = abs(currentTimeStamp - previousTimeStamp);
        let distance = abs(calculatePoseDistance(currentFramePose: currentFramePose, previousFramePose: previousFramePose));
        if(timeDiff == 0.0){
            return 0.0
        }
        let speed = Float(distance)/Float(timeDiff)
        return speed
    }
    
    func setDistanceThreshold(threshold: Int) {
        if threshold > 0 && threshold < 100 {
            distanceThreshold = threshold
        } else {
            
        }
    }
    
    func setAngleThreshold(threshold:Int){
        if (threshold>=0 && threshold <= 180){
            angleThreshold = threshold
        }
        else{
            
        }
    }
    
    /**
     Start the lidar scan that enable meshing in the ARSCNView
     */
    func startScan(){
        let config = createStartScanConfig()
        configJsonManager.createProjectFolder()
        configJsonManager.createConfigFile()
        sceneView.session.delegate = self
        sceneView.session.run(config, options: [.removeExistingAnchors, .resetSceneReconstruction, .resetTracking])
        status="scanning"
    }
    
    func dropScan(){
        if(status != "ready"){
            sceneView.session.pause()
            configJsonManager.deleteProjecFolder()
        }
    }
    
    func createStartScanConfig() ->ARConfiguration{
        let config = ARWorldTrackingConfiguration()
        config.environmentTexturing = .automatic
        config.sceneReconstruction = .mesh
        config.worldAlignment = .gravity
        if type(of: config).supportsFrameSemantics(.smoothedSceneDepth) {
            config.frameSemantics = .smoothedSceneDepth
        }else if(type(of: config).supportsFrameSemantics(.sceneDepth)){
            config.frameSemantics = .sceneDepth
        }
        return config
    }
    
    func pauseScan(){
        sceneView.session.pause()
    }
    
    func stopScan(){
        pauseScan();
        status="finished"
    }
    
    func saveScan(uuid:UUID)-> Bool{
        guard let camera = sceneView.session.currentFrame?.camera else {
            return false}
        self.configJsonManager.updateCover();
       let arSession = sceneView.session
        if let meshAnchors = sceneView.session.currentFrame?.anchors.compactMap({ $0 as? ARMeshAnchor }),
           let asset = convertToAsset(meshAnchors: meshAnchors) {
            do {
                try configJsonManager.exportRawMeshToObj(asset: asset)
            } catch {
                logger.error("exportRawMesh fail to \(self.configJsonManager.getRawMeshURL())")
            }
        }
        configJsonManager.writeJsonInfo();
        
        return true
    }
    
 
    

    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    
    
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
    

    
    func savePointCloud(){
        
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

