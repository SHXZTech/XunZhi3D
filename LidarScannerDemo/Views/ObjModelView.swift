import SwiftUI
import SceneKit

struct ObjModelView: UIViewRepresentable {
    var objURL: URL

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = createScene()
        scnView.allowsCameraControl = true // Optional: allows user to manipulate camera
        scnView.autoenablesDefaultLighting = true // Automatically adds a light source
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    private func createScene() -> SCNScene {
        let scene = SCNScene()
        let node = SCNNode()

        // Load the .obj file from the provided URL
        if let modelScene = try? SCNScene(url: objURL, options: nil) {
            for childNode in modelScene.rootNode.childNodes {
                node.addChildNode(childNode)
            }
        }

        scene.rootNode.addChildNode(node)
        return scene
    }
}

