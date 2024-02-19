import SwiftUI
import SceneKit
import SceneKit.ModelIO

struct ObjModelMeasureView: UIViewRepresentable {
    var objURL: URL
    @Binding var isMeasureActive: Bool
    @Binding var measuredDistance: Double
    @Binding var isMeasuredFirstPoint: Bool
    @Binding var isReturnToInit: Bool
    
    @Binding var isPipelineActive: Bool
    @Binding var isPipelineDrawFirstPoint: Bool
    @Binding var isPipelineReturnOneStep: Bool
    @Binding var isExportImage:Bool
    @Binding var exportedImage: Image?
    
    @Binding var isModelLoading:Bool;
    
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.delegate = context.coordinator
        createScene { loadedScene in
                scnView.scene = loadedScene
            }
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        scnView.backgroundColor = UIColor.black
        // New pan gesture recognizer for two-finger drag
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        panGesture.minimumNumberOfTouches = 2  // Require two fingers
        panGesture.maximumNumberOfTouches = 2
        scnView.addGestureRecognizer(panGesture)
        if let gestures = scnView.gestureRecognizers {
            for gesture in gestures {
                if let rotationGesture = gesture as? UIRotationGestureRecognizer {
                    rotationGesture.isEnabled = false
                }
            }
        }
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // MeasureMent Mode
        if isMeasureActive{
            if isReturnToInit{
                context.coordinator.clearMeasurements()
            }
        }else{
            context.coordinator.clearMeasurements()
        }
        
        // PipeLine Mode
        if isPipelineActive {
            context.coordinator.handlePipelineMode()
            if isPipelineReturnOneStep {
                context.coordinator.removeLastPipelineNode()
                DispatchQueue.main.async {
                    self.isPipelineReturnOneStep = false
                }
            }
            if isExportImage {
                let snapshot = context.coordinator.exportCurrentView(uiView)
                DispatchQueue.main.async {
                    if let snapshot = snapshot {
                        self.exportedImage = Image(uiImage: snapshot)
                    }
                    self.isExportImage = false
                }
            }
        } else {
            context.coordinator.clearPipelines()
        }
    }
    
    func createPipelineScene(with pipelineNodes: [SCNNode]) -> SCNScene {
        let scene = SCNScene()
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        // Adjust camera position and orientation
        cameraNode.position = SCNVector3(x: 10, y: 10, z: 10)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
        
        for node in pipelineNodes {
            // Clone each node to avoid modifying the original scene
            let clonedNode = node.clone()
            scene.rootNode.addChildNode(clonedNode)
        }
        
        return scene
    }
    
    func capturePipelineImage(from pipelineNodes: [SCNNode]) -> UIImage? {
        let pipelineScene = createPipelineScene(with: pipelineNodes)
        let scnView = SCNView()
        scnView.scene = pipelineScene
        scnView.pointOfView = pipelineScene.rootNode.childNodes.first(where: { $0.camera != nil })
        // Capture the current frame of the scene
        let renderer = scnView.snapshot()
        return renderer
    }
    
    private func createScene(completion: @escaping (SCNScene) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let scene = SCNScene()
            if let modelScene = try? SCNScene(url: self.objURL, options: nil) {
                let node = SCNNode()
                var nodeCount = 1

                for childNode in modelScene.rootNode.childNodes {
                    node.addChildNode(childNode)
                    nodeCount += 1
                }
                scene.rootNode.addChildNode(node)
            }
            DispatchQueue.main.async {
                completion(scene)
                self.isModelLoading = false
            }
        }
    }

    
    class Coordinator: NSObject , SCNSceneRendererDelegate {
        var parent: ObjModelMeasureView
        var firstPoint: SCNVector3?
        var secondPoint: SCNVector3?
        var measurementNodes: [SCNNode] = []
        var pipelineNodes: [SCNNode] = []
        var pipelinePoints: [SCNVector3] = []
        init(_ parent: ObjModelMeasureView) {
            self.parent = parent
        }
        
        @objc func handlePan(_ gestureRecognize: UIPanGestureRecognizer) {
            guard let scnView = gestureRecognize.view as? SCNView else { return }
            if gestureRecognize.numberOfTouches == 2 {
                let translation = gestureRecognize.translation(in: scnView)
                if let cameraNode = scnView.pointOfView {
                    let cameraOrientation = cameraNode.orientation
                    var translationVector = SCNVector3(-Float(translation.x) / 100.0, Float(translation.y) / 100.0, 0)
                    translationVector = translationVector.transformed(by: cameraOrientation)
                    let newCameraPosition = SCNVector3(
                        cameraNode.position.x + translationVector.x,
                        cameraNode.position.y + translationVector.y,
                        cameraNode.position.z + translationVector.z
                    )
                    cameraNode.position = newCameraPosition
                }
                gestureRecognize.setTranslation(CGPoint.zero, in: scnView)
            }
        }


        @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
            guard let scnView = gestureRecognize.view as? SCNView,
                  let scene = scnView.scene else { return }
            
            let point = gestureRecognize.location(in: scnView)
            let hitResults = scnView.hitTest(point, options: [:])
            
            if let hitResult = hitResults.first {
                let tappedPoint = hitResult.worldCoordinates
                // Handle measure mode
                if parent.isMeasureActive {
                    if firstPoint == nil {
                        firstPoint = tappedPoint
                        addPoint(at: tappedPoint, to: scene)
                        self.parent.isMeasuredFirstPoint = true
                    } else if secondPoint == nil {
                        secondPoint = tappedPoint
                        addPoint(at: tappedPoint, to: scene)
                        if let firstPoint = firstPoint {
                            addLineBetween(firstPoint, secondPoint!, to: scene)
                        }
                    } else {
                        firstPoint = nil
                        secondPoint = nil
                    }
                }
                
                // Handle pipeline mode
                if parent.isPipelineActive {
                    pipelinePoints.append(tappedPoint)
                    addPoint(at: tappedPoint, to: scene)
                    
                    if pipelinePoints.count > 1 {
                        let start = pipelinePoints[pipelinePoints.count - 2]
                        let end = tappedPoint
                        addLineBetween(start, end, to: scene)
                    }
                    DispatchQueue.main.async {
                        self.parent.isPipelineDrawFirstPoint = true
                    }
                }
            }
        }
        
        func handlePipelineMode() {
            // Logic to handle pipeline mode
        }
        
        func exportCurrentView(_ scnView: SCNView) -> UIImage? {
            // Take a snapshot of the current view, including the 3D model and pipeline
            let snapshot = scnView.snapshot()
            return snapshot
        }
        
        func removeLastPipelineNode() {
            guard !pipelinePoints.isEmpty else { return }

            if pipelinePoints.count <= 2 {
                pipelinePoints.removeAll()
                // Remove each node from its parent before clearing the array
                for node in pipelineNodes {
                    node.removeFromParentNode()
                }
                pipelineNodes.removeAll()
            } else {
                pipelinePoints.removeLast()
                let totalNodesToRemove = 4 // Number of nodes per point (sphere, label, text, line)
                if pipelineNodes.count >= totalNodesToRemove {
                    for _ in 0..<totalNodesToRemove {
                        if let nodeToRemove = pipelineNodes.popLast() {
                            nodeToRemove.removeFromParentNode()
                        }
                    }
                }
            }
        }
        
        private func addPoint(at position: SCNVector3, to scene: SCNScene) {
            var radius_ = 0.02
            var color_ = UIColor.systemRed
            if self.parent.isMeasureActive{
                radius_ = 0.02
                color_ = UIColor.systemRed
            }
            if self.parent.isPipelineActive{
                radius_ = 0.04
                color_ = UIColor.systemYellow
            }
            let sphere = SCNSphere(radius: radius_) // Adjust size as needed
            let material = SCNMaterial()
            material.diffuse.contents = color_// Choose your desired color here
            material.shininess = 1.0 // Adjust for shininess, range is typically 0.0 to 1.0
            material.lightingModel = .constant // Use a constant lighting model for no reflections
            sphere.materials = [material]
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = position
            sphereNode.renderingOrder = 1000
            sphereNode.geometry?.firstMaterial?.writesToDepthBuffer = false
            scene.rootNode.addChildNode(sphereNode)
            if self.parent.isPipelineActive{
                pipelineNodes.append(sphereNode)
            }
            if self.parent.isMeasureActive{
                measurementNodes.append(sphereNode)
            }
        }
        
        private func addLineBetween(_ start: SCNVector3, _ end: SCNVector3, to scene: SCNScene) {
            let vector = end - start
            let length = vector.length()
            var radius_ = 0.01
            var color_ = UIColor.systemRed
            if self.parent.isMeasureActive{
                radius_ = 0.01
                color_ = UIColor.systemRed
            }
            if self.parent.isPipelineActive{
                radius_ = 0.02
                color_ = UIColor.systemYellow
            }
            let cylinder = SCNCylinder(radius: radius_, height: CGFloat(length)) // Adjust radius for line thickness
            cylinder.radialSegmentCount = 100 // Can be increased for smoother appearance
            // Set the material of the cylinder
            let material = SCNMaterial()
            material.diffuse.contents = color_ // Set the line color here
            material.specular.contents = UIColor.white
            material.shininess = 10.0
            material.lightingModel = .constant
            cylinder.materials = [material]
            let lineNode = SCNNode(geometry: cylinder)
            // Position and rotate the cylinder
            lineNode.position = (start + end) / 2
            lineNode.renderingOrder = 1000
            lineNode.look(at: end, up: scene.rootNode.worldUp, localFront: lineNode.worldUp)
            scene.rootNode.addChildNode(lineNode)
            let midpoint = (start + end) / 2
            let distance = (end - start).length()
            DispatchQueue.main.async {
                self.parent.measuredDistance = Double(distance)
                self.parent.isMeasuredFirstPoint = true
            }
            let distanceText = String(format: "%.2f 米", distance) // Format as needed
            addLabel(text: distanceText, at: midpoint, to: scene)
            if self.parent.isMeasureActive{
                measurementNodes.append(lineNode)}
            if self.parent.isPipelineActive{
                pipelineNodes.append(lineNode)
            }
        }
        
        private func addLabel(text: String, at position: SCNVector3, to scene: SCNScene) {
            // Create a node to hold the text and background
            let labelNode = SCNNode()
            var label_size: CGFloat = 5
            var color_ = UIColor.systemRed
            if self.parent.isMeasureActive{
                label_size = 5
                color_ = UIColor.systemRed
            }
            if self.parent.isPipelineActive{
                label_size = 10
                color_ = UIColor.systemYellow
            }
            // Create the text geometry with specified font size
            let textGeometry = SCNText(string: text, extrusionDepth: 0.1)
            textGeometry.font = UIFont.systemFont(ofSize: label_size) // Set your desired font size here
            // Set the color of the text
            let textMaterial = SCNMaterial()
            textMaterial.diffuse.contents = color_ // Set your desired text color here
            textGeometry.materials = [textMaterial]
            let textNode = SCNNode(geometry: textGeometry)
            // Set the scale for the text - adjust as needed
            let textScale: CGFloat = 0.02
            textNode.scale = SCNVector3(textScale, textScale, textScale)
            textNode.position = SCNVector3(0, 0, 0)
            labelNode.addChildNode(textNode)
            // Position the label node
            labelNode.position = position
            // Apply a billboard constraint to make the label always face the camera
            labelNode.constraints = [SCNBillboardConstraint()]
            // Set rendering order
            labelNode.renderingOrder = 1000
            textNode.renderingOrder = 1000
            // Ensure the label is always rendered on top
            labelNode.geometry?.firstMaterial?.writesToDepthBuffer = false
            scene.rootNode.addChildNode(labelNode)
            if self.parent.isMeasureActive{
                measurementNodes.append(labelNode)
                measurementNodes.append(textNode)
            }
            if self.parent.isPipelineActive{
                pipelineNodes.append(labelNode)
                pipelineNodes.append(textNode)
            }
        }
        
        func clearMeasurements() {
            DispatchQueue.main.async {
                // Clear the measurement nodes
                for node in self.measurementNodes {
                    node.removeFromParentNode()
                }
                self.measurementNodes.removeAll()
                self.firstPoint = nil
                self.secondPoint = nil
                self.parent.measuredDistance = 0.0
                self.parent.isMeasuredFirstPoint = false
                self.parent.isReturnToInit = false
            }
        }
        
        func clearPipelines(){
            DispatchQueue.main.async{
                for node in self.pipelineNodes{
                    node.removeFromParentNode()
                }
                self.pipelineNodes.removeAll()
                self.pipelinePoints.removeAll()
                self.parent.isPipelineDrawFirstPoint = false
                self.parent.isPipelineReturnOneStep = false
                self.parent.isExportImage = false
                self.parent.exportedImage = nil
            }
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            //adjustNodeSizes(renderer: renderer)
        }
        
        private func adjustNodeSizes(renderer: SCNSceneRenderer) {
            guard let cameraNode = renderer.pointOfView else { return }
            // Define the desired screen size for points and lines
            let desiredScreenSize: CGFloat = 50.0 // Adjust as needed
            for node in renderer.scene?.rootNode.childNodes ?? [] {
                guard let geometry = node.geometry else { continue }
                if geometry is SCNSphere || geometry is SCNCylinder {
                    let distance = distanceFromCamera(node: node, cameraNode: cameraNode, renderer: renderer)
                    let scale = scaleForDistance(distance, desiredSize: desiredScreenSize)
                    node.scale = SCNVector3(scale, scale, scale)
                }
            }
        }
        
        private func distanceFromCamera(node: SCNNode, cameraNode: SCNNode, renderer: SCNSceneRenderer) -> CGFloat {
            let nodePosition = renderer.projectPoint(node.worldPosition)
            let cameraPosition = renderer.projectPoint(cameraNode.worldPosition)
            return CGFloat(hypotf(Float(nodePosition.x - cameraPosition.x), Float(nodePosition.y - cameraPosition.y)))
        }
        
        private func scaleForDistance(_ distance: CGFloat, desiredSize: CGFloat) -> CGFloat {
            // Adjust the formula as needed to achieve the desired effect
            return max(1.0, desiredSize / max(distance, 1))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}


extension SCNGeometry {
    static func line(from start: SCNVector3, to end: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [start, end])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}

extension SCNVector3 {
    static func -(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
    static func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    static func /(lhs: SCNVector3, rhs: Float) -> SCNVector3 {
        return SCNVector3(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    }
    func length() -> Float {
        return sqrt(x * x + y * y + z * z)
    }
}


extension SCNVector3 {
    func transformed(by orientation: SCNQuaternion) -> SCNVector3 {
        let glQuaternion = GLKQuaternionMake(orientation.x, orientation.y, orientation.z, orientation.w)
        let glVector = GLKVector3Make(self.x, self.y, self.z)
        let transformedVector = GLKQuaternionRotateVector3(glQuaternion, glVector)
        return SCNVector3(transformedVector.x, transformedVector.y, transformedVector.z)
    }
}
