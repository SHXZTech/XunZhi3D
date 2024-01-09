import SwiftUI
import SceneKit

struct ObjModelMeasureView: UIViewRepresentable {
    var objURL: URL
    
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
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
    
    class Coordinator: NSObject , SCNSceneRendererDelegate {
        var parent: ObjModelMeasureView
        var firstPoint: SCNVector3?
        var secondPoint: SCNVector3?
        init(_ parent: ObjModelMeasureView) {
            self.parent = parent
        }
        @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
            guard let scnView = gestureRecognize.view as? SCNView,
                  let scene = scnView.scene else { return }
            let point = gestureRecognize.location(in: scnView)
            let hitResults = scnView.hitTest(point, options: [:])
            // Check if the tap was on the model
            if let hitResult = hitResults.first {
                let tappedPoint = hitResult.worldCoordinates
                
                if firstPoint == nil {
                    firstPoint = tappedPoint
                    addPoint(at: tappedPoint, to: scene)
                } else if secondPoint == nil {
                    secondPoint = tappedPoint
                    addPoint(at: tappedPoint, to: scene)
                    if let firstPoint = firstPoint {
                        addLineBetween(firstPoint, secondPoint!, to: scene)
                    }
                } else {
                    // Reset points if two are already selected
                    firstPoint = nil
                    secondPoint = nil
                    // Optionally, clear existing points and lines from the scene
                }
            }
        }
        
        private func addPoint(at position: SCNVector3, to scene: SCNScene) {
            let sphere = SCNSphere(radius: 0.01) // Adjust size as needed
            // Create a material for the sphere
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.systemRed // Choose your desired color here
            material.shininess = 1.0 // Adjust for shininess, range is typically 0.0 to 1.0
            material.lightingModel = .constant // Use a constant lighting model for no reflections
            // Assign the material to the sphere
            sphere.materials = [material]
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = position
            sphereNode.renderingOrder = 999
            sphereNode.geometry?.firstMaterial?.writesToDepthBuffer = false
            scene.rootNode.addChildNode(sphereNode)
        }
        
        private func addLineBetween(_ start: SCNVector3, _ end: SCNVector3, to scene: SCNScene) {
            let vector = end - start
            let length = vector.length()
            let cylinder = SCNCylinder(radius: 0.006, height: CGFloat(length)) // Adjust radius for line thickness
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
            lineNode.renderingOrder = 999
            lineNode.look(at: end, up: scene.rootNode.worldUp, localFront: lineNode.worldUp)
            scene.rootNode.addChildNode(lineNode)
            let midpoint = (start + end) / 2
            let distance = (end - start).length()
            let distanceText = String(format: "%.3f 米", distance) // Format as needed
            addLabel(text: distanceText, at: midpoint, to: scene)
        }
        
        private func addLabel(text: String, at position: SCNVector3, to scene: SCNScene) {
            // Create a node to hold the text and background
            let labelNode = SCNNode()
            // Create the text geometry
            let textGeometry = SCNText(string: text, extrusionDepth: 0.1)
            textGeometry.font = UIFont.systemFont(ofSize: 1) // Adjust font size
            let textNode = SCNNode(geometry: textGeometry)
            // Set the scale for the text
            let textScale: CGFloat = 0.02
            textNode.scale = SCNVector3(textScale, textScale, textScale)
            // Calculate the text's size
            // Adjust text node position to center
            textNode.position = SCNVector3(0, 0, 0)
            labelNode.addChildNode(textNode)
            // Position the label node
            labelNode.position = position
            // Apply a billboard constraint to make the label always face the camera
            labelNode.constraints = [SCNBillboardConstraint()]
            // Set rendering order
            labelNode.renderingOrder = 1000
            textNode.renderingOrder = 1000
            labelNode.geometry?.firstMaterial?.writesToDepthBuffer = false
            scene.rootNode.addChildNode(labelNode)
        }

        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            adjustNodeSizes(renderer: renderer)
        }
        
        private func adjustNodeSizes(renderer: SCNSceneRenderer) {
            guard let cameraNode = renderer.pointOfView else { return }
            // Define the desired screen size for points and lines
            let desiredScreenSize: CGFloat = 30.0 // Adjust as needed
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
