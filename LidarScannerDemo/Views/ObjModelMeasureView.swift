import SwiftUI
import SceneKit
import SceneKit.ModelIO
import GLTFSceneKit


struct ObjModelMeasureView: UIViewRepresentable {
    var objURL: URL
    // Point measure var
    @Binding var isPointMeasureActive: Bool
    @Binding var point_x: Double;
    @Binding var point_y: Double;
    @Binding var point_z: Double;
    
    // Line measure var
    @Binding var isMeasureActive: Bool
    @Binding var measuredDistance: Double
    @Binding var isMeasuredFirstPoint: Bool
    @Binding var isReturnToInit: Bool
    
    // Pipeline measure var
    @Binding var isPipelineActive: Bool
    @Binding var isPipelineDrawFirstPoint: Bool
    @Binding var isPipelineReturnOneStep: Bool
    @Binding var isExportImage:Bool
    @Binding var exportedImage: Image?
    
    @Binding var isModelLoading:Bool;
    
    @Binding var isExportCAD:Bool;
    @Binding var exported_CAD_url: URL?
    
    
    func makeUIView(context: Context) -> SCNView {
        print("直接显示glb文件时，这个方法没有执行")
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
            
            if isExportCAD {
                DispatchQueue.main.async {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let dxfFilePath = documentsDirectory.appendingPathComponent("pipeline.dxf").path
                    context.coordinator.exportCombinedDXF(to: dxfFilePath)
                    
                    // Now that the file has been created, convert the file path to a URL
                    self.exported_CAD_url = URL(fileURLWithPath: dxfFilePath)
                    
                    // Reset the flag to indicate the export process is complete
                    self.isExportCAD = false
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
    
//    private func createScene(completion: @escaping (SCNScene) -> Void) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            print("final show self.objURL is == == == ",self.objURL)
//            let scene = SCNScene()
//            if let modelScene = try? SCNScene(url: self.objURL, options: nil) {
//                let node = SCNNode()
//                var nodeCount = 1
//
//                for childNode in modelScene.rootNode.childNodes {
//                    node.addChildNode(childNode)
//                    nodeCount += 1
//                }
//                scene.rootNode.addChildNode(node)
//            }
//            DispatchQueue.main.async {
//                completion(scene)
//                self.isModelLoading = false
//            }
//        }
//    }
    
    private func createScene(completion: @escaping (SCNScene) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            print("final show self.objURL is == == == ", self.objURL)
            
            let scene = SCNScene()
            
            // 判断文件是否是 .glb 格式
            if self.objURL.pathExtension.lowercased() == "glb" {
                do {
                    // 使用 GLTFSceneSource 加载 .glb 文件
                    let source = GLTFSceneSource(url: self.objURL)
                    let gltfScene = try source.scene()
                    
                    // 将加载的 GLTF 场景添加到 SCNScene
                    scene.rootNode.addChildNode(gltfScene.rootNode)
                } catch {
                    print("Error loading GLB model: \(error)")
                }
            } else {
                // 处理 OBJ 文件
                if let modelScene = try? SCNScene(url: self.objURL, options: nil) {
                    let node = SCNNode()
                    var nodeCount = 1
                    
                    for childNode in modelScene.rootNode.childNodes {
                        node.addChildNode(childNode)
                        nodeCount += 1
                    }
                    scene.rootNode.addChildNode(node)
                }
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
                //Handle point measure mode
                if parent.isPointMeasureActive{
                    addPoint(at: tappedPoint, to: scene)
                    parent.point_x = Double(tappedPoint.x)
                    parent.point_y = Double(tappedPoint.y)
                    parent.point_z = Double(tappedPoint.z)
                }
                
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
            if let cameraNode = scnView.pointOfView {
                    // Extrinsic parameters: Camera's position and orientation
                    let position = cameraNode.position // SCNVector3
                    let orientation = cameraNode.orientation // SCNQuaternion

                    // Intrinsic parameters can be approximated from the camera node's properties
                    // Note: SceneKit's SCNCamera does not directly expose fx, fy, but you can use fieldOfView and aspect ratio
                    if let camera = cameraNode.camera {
                        let fieldOfView = camera.fieldOfView // Y-axis field of view in degrees
                        let aspectRatio = scnView.bounds.size.width / scnView.bounds.size.height
                        // Assuming a simple pinhole camera model to relate FOV and focal length
                        let fy = 0.5 / tan(fieldOfView * 0.5 * Double.pi / 180) * Double(scnView.bounds.size.height)
                        let fx = fy * Double(aspectRatio) // Assuming square pixels (fx = fy * aspect ratio)
                    }
                }
            return snapshot
        }
             
        func exportCombinedDXF(to filePath: String) {
        let pipelinePoints = self.pipelinePoints
        var dxfContent = """
        0
        SECTION
        2
        HEADER
        0
        ENDSEC
        0
        SECTION
        2
        TABLES
        0
        ENDSEC
        0
        SECTION
        2
        BLOCKS
        0
        ENDSEC
        0
        SECTION
        2
        ENTITIES
        """

        // Define an offset for the side view to separate it from the top-down view
        let sideViewOffsetX: Float = 5.0  // Adjust as needed for layout

        // Generate top-down view content with distances
        for (index, point) in pipelinePoints.enumerated() where index < pipelinePoints.count - 1 {
            let startPoint = point
            let endPoint = pipelinePoints[index + 1]
            let distance = sqrt(pow(endPoint.x - startPoint.x, 2) + pow(endPoint.y - startPoint.y, 2) + pow(endPoint.z - startPoint.z, 2))
            let distanceText = "\(String(format: "%.2f", distance))m"

            // Top-down view lines
            dxfContent += """
            \n0
            LINE
            8
            TopDownView
            10
            \(startPoint.x)
            20
            \(startPoint.z)
            30
            0
            11
            \(endPoint.x)
            21
            \(endPoint.z)
            31
            0
            """

            // Top-down view distance annotations
            let midPointX = (startPoint.x + endPoint.x) / 2
            let midPointZ = (startPoint.z + endPoint.z) / 2
            let textOffsetZ = (startPoint.z < endPoint.z) ? -0.5 : 0.5  // Adjust the offset based on the line direction
            dxfContent += """
            \n0
            TEXT
            8
            TopDownView
            10
            \(midPointX)
            20
            \(Float(midPointZ) + Float(textOffsetZ))
            30
            0
            40
            0.2
            1
            \(distanceText)
            """
        }

        // Determine the position for the "Top View" text label
        let topViewLabelX = pipelinePoints[0].x
        let topViewLabelZ = pipelinePoints.map { $0.z }.min()! - 1.5  // Adjust the offset to avoid overlapping

        // Add "Top View" text label
        dxfContent += """
            \n0
            TEXT
            8
            0
            10
            \(topViewLabelX)
            20
            \(topViewLabelZ)
            30
            0
            40
            0.5
            1
            Top View
            """

        // Generate side view content with distances
        for (index, point) in pipelinePoints.enumerated() where index < pipelinePoints.count - 1 {
            let startPoint = transformPointForAxialSideView(point)
            let endPoint = transformPointForAxialSideView(pipelinePoints[index + 1])

            // Side view lines with offset
            dxfContent += """
            \n0
            LINE
            8
            SideView
            10
            \(startPoint.x + sideViewOffsetX)
            20
            \(startPoint.y)
            30
            0
            11
            \(endPoint.x + sideViewOffsetX)
            21
            \(endPoint.y)
            31
            0
            """
            let startPoint_3D = point;
            let endPoint_3D = pipelinePoints[index + 1];
            // Side view distance annotations with offset
            let distance_side = sqrt(pow(endPoint_3D.x - startPoint_3D.x, 2)+pow(endPoint_3D.y - startPoint_3D
                .y, 2)+pow(endPoint_3D.z - startPoint_3D.z, 2))
            
            let distanceText = "\(String(format: "%.2f", distance_side))m"
            let midPointXOffset = (startPoint.x + endPoint.x) / 2 + sideViewOffsetX
            let midPointY = (startPoint.y + endPoint.y) / 2
            let textOffsetX = (startPoint.x < endPoint.x) ? 0.5 : -0.5  // Adjust the offset based on the line direction
            dxfContent += """
            \n0
            TEXT
            8
            SideView
            10
            \(Float(midPointXOffset) + Float(textOffsetX))
            20
            \(midPointY)
            30
            0
            40
            0.2
            1
            \(distanceText)
            """
        }

        // Determine the position for the "Side View" text label
        let sideViewStartPoint = transformPointForAxialSideView(pipelinePoints[0])
        let sideViewLabelX = sideViewStartPoint.x + sideViewOffsetX
        let sideViewLabelY = pipelinePoints.map { transformPointForAxialSideView($0).y }.max()! + 1.5  // Adjust the offset to avoid overlapping

        // Add "Side View" text label
        dxfContent += """
            \n0
            TEXT
            8
            0
            10
            \(sideViewLabelX)
            20
            \(sideViewLabelY)
            30
            0
            40
            0.5
            1
            Side View
            """

        // Close the DXF sections
        dxfContent += "\n0\nENDSEC\n0\nEOF"

        // Write the combined DXF content to a file
        do {
            try dxfContent.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
        }
        }
        
      
        private func deg2rad(_ degree: Float) -> Float {
            return degree * .pi / 180
        }

        private func crossProduct(_ a: SCNVector3, _ b: SCNVector3) -> SCNVector3 {
            return SCNVector3(
                a.y * b.z - a.z * b.y,
                a.z * b.x - a.x * b.z,
                a.x * b.y - a.y * b.x
            )
        }

        private func dotProduct(_ a: SCNVector3, _ b: SCNVector3) -> Float {
            return a.x * b.x + a.y * b.y + a.z * b.z
        }

        private func normalize(_ vector: SCNVector3) -> SCNVector3 {
            let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
            return SCNVector3(vector.x / length, vector.y / length, vector.z / length)
        }

        private func transformPointForAxialSideView(_ point: SCNVector3) -> (x: Float, y: Float) {
            // Adjust point coordinates: x = x, y = -z, z = y
            let adjustedPoint = SCNVector3(point.x, -point.z, point.y)

            // Define the plane normal vector
            let normal = SCNVector3(-sin(deg2rad(45)), -sin(deg2rad(45)), cos(deg2rad(45)))

            // Normalize the plane normal vector
            let normalizedNormal = normalize(normal)

            // Define the basis vectors for the projected plane
            let basisU = normalize(crossProduct(normalizedNormal, SCNVector3(0, 0, 1)))
            let basisV = normalize(crossProduct(normalizedNormal, basisU))

            // Project the adjusted point onto the plane
            let u = -dotProduct(adjustedPoint, basisU)
            let v = -dotProduct(adjustedPoint, basisV)

            return (u, v)
        }

       // Matrix multiplication (matrix * matrix)
        func multiplyMatrices(A: [[Float]], B: [[Float]]) -> [[Float]] {
            let rowsA = A.count
            let colsA = A[0].count
            let colsB = B[0].count

            var result = Array(repeating: Array(repeating: Float(0), count: colsB), count: rowsA) // Explicitly use Float(0)
              
            for i in 0..<rowsA {
                for j in 0..<colsB {
                    for k in 0..<colsA {
                        result[i][j] += A[i][k] * B[k][j]
                    }
                }
            }
            return result
        }

        // Matrix-vector multiplication
        func multiplyMatrixAndVector(matrix: [[Float]], vector: [Float]) -> [Float] {
            var result: [Float] = Array(repeating: 0.0, count: matrix.count)
            for i in 0..<matrix.count {
                for j in 0..<vector.count {
                    result[i] += matrix[i][j] * vector[j]
                }
            }
            return result
        }

        // Helper functions to perform matrix-vector and matrix-matrix multiplication would be needed here

        
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
            if self.parent.isPointMeasureActive{
                radius_ = 0.02
                color_ = UIColor.systemCyan
            }
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
