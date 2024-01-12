import SwiftUI
import SceneKit

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
    
    var pipelineNodes: [SCNNode] = []
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = createScene()
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.delegate = context.coordinator
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if !isMeasureActive {
            context.coordinator.clearMeasurements()
        }
        if isReturnToInit{
            context.coordinator.clearMeasurements()
        }
        if isPipelineActive {
            context.coordinator.handlePipelineMode()
        } else {
            context.coordinator.clearPipelineNodes()
        }
        if isPipelineReturnOneStep {
               context.coordinator.removeLastPipelineNode()
               isPipelineReturnOneStep = false
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

    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        // Load the 3D model from the provided URL
        if let modelScene = try? SCNScene(url: objURL, options: nil) {
            let node = SCNNode()
            for childNode in modelScene.rootNode.childNodes {
                node.addChildNode(childNode)
            }
            scene.rootNode.addChildNode(node)
        }
        return scene
    }
    
    class Coordinator: NSObject , SCNSceneRendererDelegate {
        var parent: ObjModelMeasureView
        var firstPoint: SCNVector3?
        var secondPoint: SCNVector3?
        var measurementNodes: [SCNNode] = []
        var pipelinePoints: [SCNVector3] = []
        
        init(_ parent: ObjModelMeasureView) {
            self.parent = parent
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
                
                // Remove the last point
                let lastPointIndex = pipelinePoints.count - 1
                pipelinePoints.removeLast()
                
                // Also remove the corresponding node from the scene, if it exists
                if lastPointIndex < measurementNodes.count {
                    let lastNode = measurementNodes[lastPointIndex]
                    lastNode.removeFromParentNode()
                    measurementNodes.removeLast()
                }

                // If there's a line connected to the last point, remove it as well
                if lastPointIndex > 0 && lastPointIndex - 1 < measurementNodes.count {
                    let lineNodeIndex = lastPointIndex - 1
                    let lineNode = measurementNodes[lineNodeIndex]
                    lineNode.removeFromParentNode()
                    measurementNodes.remove(at: lineNodeIndex)
                }
            }
        
        
        func clearPipelineNodes() {
            for node in parent.pipelineNodes {
                node.removeFromParentNode()
            }
            parent.pipelineNodes.removeAll()
            pipelinePoints.removeAll()
        }
        
        private func addPoint(at position: SCNVector3, to scene: SCNScene) {
            let sphere = SCNSphere(radius: 0.02) // Adjust size as needed
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.systemRed // Choose your desired color here
            material.shininess = 1.0 // Adjust for shininess, range is typically 0.0 to 1.0
            material.lightingModel = .constant // Use a constant lighting model for no reflections
            sphere.materials = [material]
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = position
            sphereNode.renderingOrder = 1000
            sphereNode.geometry?.firstMaterial?.writesToDepthBuffer = false
            scene.rootNode.addChildNode(sphereNode)
            measurementNodes.append(sphereNode)
        }
        
        private func addLineBetween(_ start: SCNVector3, _ end: SCNVector3, to scene: SCNScene) {
            let vector = end - start
            let length = vector.length()
            let cylinder = SCNCylinder(radius: 0.01, height: CGFloat(length)) // Adjust radius for line thickness
            cylinder.radialSegmentCount = 100 // Can be increased for smoother appearance
            // Set the material of the cylinder
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.systemRed // Set the line color here
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
            measurementNodes.append(lineNode)
        }
        
        private func addLabel(text: String, at position: SCNVector3, to scene: SCNScene) {
            // Create a node to hold the text and background
            let labelNode = SCNNode()

            // Create the text geometry with specified font size
            let textGeometry = SCNText(string: text, extrusionDepth: 0.1)
            textGeometry.font = UIFont.systemFont(ofSize: 5) // Set your desired font size here

            // Set the color of the text
            let textMaterial = SCNMaterial()
            textMaterial.diffuse.contents = UIColor.red // Set your desired text color here
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
            measurementNodes.append(labelNode)
            measurementNodes.append(textNode)
        }

        
        func clearMeasurements() {
            DispatchQueue.main.async {
                // Clear the measurement nodes
                for node in self.measurementNodes {
                    node.removeFromParentNode()
                }
                self.measurementNodes.removeAll()
                // Reset the points and state
                self.firstPoint = nil
                self.secondPoint = nil
                self.parent.measuredDistance = 0.0
                self.parent.isMeasuredFirstPoint = false
                self.parent.isReturnToInit = false
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
                    print("current scale = ", scale)
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
