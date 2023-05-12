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

private let logger = Logger(subsystem: "com.graphopti.lidarScannerDemo",
                            category: "lidarScannerDemoDelegate")

class LidarMeshModel:NSObject, ARSessionDelegate {
    private(set) var sceneView : ARSCNView // The ARSCNView used to display the scene.
    
    var uuid:UUID // The UUID of the scan.
    
    private var status:String? // The current status of the scan ("ready", "scanning", or "finished").
    
    enum CaptureMode {
        /// The user has selected manual capture mode, which captures one
        /// image per button press.
        case lidar
        
        case manual
        
        case auto
        //case ar
        
        /// The user has selected automatic capture mode, which captures one
        /// image every specified interval.
        // case automatic(everySecs: Double)
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
    
    /**
     Init the class, configure and run the sceneView
     */
    init(uuid_: UUID) {
        status = "ready"
        sceneView = ARSCNView(frame: .zero)
        uuid = uuid_
        super.init()
        //sceneView.delegate = context.coordinator
        let config = ARWorldTrackingConfiguration()
        sceneView.session.delegate = self
        sceneView.session.run(config)
        sceneView.addCoaching()
#if DEBUG
        //sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints, SCNDebugOptions.showCameras]
#endif
        setAngleThreshold(threshold: 10) // set to 10cm
        setDistanceThreshold(threshold: 10) // set to 10 degree
    }
    
    /**
     Inherite from ARSessionDelegate, this function used to save scan data. When a arFrame updates, it toggles this function.
     */
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let currentTransform = frame.camera.transform
        let currentFrameTimeStamp = frame.timestamp
        let currentFramePose = frame.camera.transform
        //too fast check
        if(status == "scanning" && tooFastCheck(currentFramePose: currentFramePose, currentTimeStamp: currentFrameTimeStamp, previousFramePose: previousFramePose, previousTimeStamp: previousFrameTimeStamp)){
            //something to buzz
            print("too fast!! check success")
            //update previousFrameTimeStamp and previopusFramePose
            previousFrameTimeStamp = frame.timestamp
            previousFramePose = frame.camera.transform
            return
        }
        //update previousFrameTimeStamp and previopusFramePose
        previousFrameTimeStamp = frame.timestamp
        previousFramePose = frame.camera.transform
        //new frame save
        if(status == "scanning" && newFrameCheck(currentFramePose: currentTransform, previousFramePose: previousSavedFramePose))
        {
            previousSavedFramePose = currentTransform
            //save timestamp
            let timeStamp = frame.timestamp
            //save intrinsic
            let intrinsic = frame.camera.intrinsics
            //save pose
            let currentTransform = frame.camera.transform
            //save RGB image
            guard let jpegData = frame.capturedjpegData() else { return  }
            if(saveJpegData(jpegData: jpegData, uuid: uuid, timeStamp: timeStamp, type: "RGB") == false){return}
            //save lidar depth
            if(frame.sceneDepth != nil) || (frame.smoothedSceneDepth != nil) {
                guard let depthImage = frame.lidarDepthData() else {
                    return}
                if(saveTiffData(pngData: depthImage, uuid: uuid, timeStamp: timeStamp, type: "Depth") == false){
                    return}
                guard let confidenceImage = frame.lidarConfidenceData() else {
                    return}
                if(saveTiffData(pngData: confidenceImage,uuid: uuid, timeStamp: timeStamp,type: "Confidence") == false){
                    return}
            }
            //save GPS
            
            //save RTK
            
            
            
        }
        
    }
    
    /**
     Check whether the new frame is accetable, it check whether the overlap/distance/angle between frames meet the threholds
     
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
        print("speed is \(speed)")
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
        //config.frameSemantics = .sceneDepth
        sceneView.session.delegate = self
        sceneView.session.run(config, options: [.removeExistingAnchors, .resetSceneReconstruction, .resetTracking])
        status="scanning"
        //creat project folder
        createProjectFolder()
        //creat Json file to record project info
        createProjectJson()
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
    
    func createProjectFolder(){
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(uuid.uuidString)
        do {
            try FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true, attributes: nil)
            logger.info("CreateProjectFolder success at: \(fileURL)")
        } catch let error {
            logger.error("Error creating directory: \(error.localizedDescription)")
        }
    }
    
    func createProjectJson(){
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(uuid.uuidString)
        let jsonFileURL = fileURL.appendingPathComponent("info.json")
        let projectInfo = [
            "createDate": Date().description,
            "owner": "default",
            "uuid" : uuid.uuidString,
            "frameCount" : "0",
            "type" : mode
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: projectInfo, options: .prettyPrinted)
            try jsonData.write(to: jsonFileURL)
            logger.info("create json file success at \(jsonFileURL)")
        } catch let error {
            logger.error("Error creating project JSON file: \(error.localizedDescription)")
        }
    }
    
    
    func saveScanProjectInfo(){
        //save uuid
        //save owner
        //save data type
        //save data count
        
        
        
    }
    
    func saveScanData(frame: ARFrame) {
        let timeStamp = frame.timestamp
        let intrinsic = frame.camera.intrinsics
        let extrinsic = frame.camera.transform
        
        let fileManager = FileManager.default
        let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(uuid.uuidString)
        let jsonFileURL = fileURL.appendingPathComponent("info.json")
        
        do {
            // Load existing JSON data from file
            var jsonData = try Data(contentsOf: jsonFileURL)
            var projectInfo = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] ?? [:]
            // Update with new data
            let scanData = [
                "timestamp": timeStamp.description,
                "intrinsic": intrinsic,
                "currentTransform": extrinsic
            ] as [String : Any]
            // Save updated JSON data back to file
            jsonData = try JSONSerialization.data(withJSONObject: projectInfo, options: .prettyPrinted)
            try jsonData.write(to: jsonFileURL)
            logger.info("Successfully saved scan data to info.json")
        } catch let error {
            logger.error("Error saving scan data: \(error.localizedDescription)")
        }
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
    
    func saveJpegData(jpegData: Data,uuid:UUID,timeStamp:TimeInterval,type:String?)-> Bool{
        if(jpegData == nil || timeStamp == nil || uuid == nil){
            return false;
        }
        
        let fileName = (type ?? "IMG") + "_" + String(format: "%.5f", timeStamp) + ".jpeg"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(uuid.uuidString).appendingPathComponent(fileName)
        let directory = fileURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("Error creating directory: \(error.localizedDescription)")
            return false;
        }
        do {
            try jpegData.write(to: fileURL)
            return true;
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return false;
        }
    }
    
    func savePngData(pngData: Data,uuid:UUID,timeStamp:TimeInterval, type : String?)-> Bool{
        if(pngData == nil || timeStamp == nil || uuid == nil){
            return false;
        }
        let fileName = (type ?? "IMG") + "_" + String(format: "%.5f", timeStamp) + ".png"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(uuid.uuidString).appendingPathComponent(fileName)
        let directory = fileURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("Error creating directory: \(error.localizedDescription)")
            return false;
        }
        do {
            try pngData.write(to: fileURL)
            return true;
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return false;
        }
    }
    
    func saveTiffData(pngData: Data,uuid:UUID,timeStamp:TimeInterval, type : String?)-> Bool{
        if(pngData == nil || timeStamp == nil || uuid == nil){
            return false;
        }
        let fileName = (type ?? "IMG") + "_" + String(format: "%.5f", timeStamp) + ".TIF"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(uuid.uuidString).appendingPathComponent(fileName)
        let directory = fileURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("Error creating directory: \(error.localizedDescription)")
            return false;
        }
        do {
            try pngData.write(to: fileURL)
            return true;
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return false;
        }
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

