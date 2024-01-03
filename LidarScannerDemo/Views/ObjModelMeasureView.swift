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

    class Coordinator: NSObject {
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
            let sphere = SCNSphere(radius: 0.02) // Adjust size as needed
            // Create a material for the sphere
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.cyan // Choose your desired color here
            material.shininess = 1.0 // Adjust for shininess, range is typically 0.0 to 1.0
            material.lightingModel = .constant // Use a constant lighting model for no reflections

            // Assign the material to the sphere
            sphere.materials = [material]
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = position
            scene.rootNode.addChildNode(sphereNode)
        }
        
        private func addLineBetween(_ start: SCNVector3, _ end: SCNVector3, to scene: SCNScene) {
            let vector = end - start
            let length = vector.length()
            let cylinder = SCNCylinder(radius: 0.01, height: CGFloat(length)) // Adjust radius for line thickness
            cylinder.radialSegmentCount = 100 // Can be increased for smoother appearance
            // Set the material of the cylinder
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.cyan // Set the line color here
            material.specular.contents = UIColor.white
            material.shininess = 10.0
            material.lightingModel = .constant
            cylinder.materials = [material]
            let lineNode = SCNNode(geometry: cylinder)
            // Position and rotate the cylinder
            lineNode.position = (start + end) / 2
            lineNode.look(at: end, up: scene.rootNode.worldUp, localFront: lineNode.worldUp)
            scene.rootNode.addChildNode(lineNode)
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
