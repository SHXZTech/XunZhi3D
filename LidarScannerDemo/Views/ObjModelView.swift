import SwiftUI
import SceneKit

struct ObjModelView: UIViewRepresentable {
    var objURL: URL

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = createScene()
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false // Automatically adds a light source
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    private func createScene() -> SCNScene {
        let scene = SCNScene()
        let node = SCNNode()
        if let modelScene = try? SCNScene(url: objURL, options: nil) {
            for childNode in modelScene.rootNode.childNodes {
                node.addChildNode(childNode)
            }
        }
        
        scene.rootNode.addChildNode(node)
        return scene
    }
}

struct ObjModelView_Previews: PreviewProvider {
    static var previews: some View {
        guard let objURL = Bundle.main.url(forResource: "textured", withExtension: "obj") else {
            fatalError("Failed to find model file.")
        }

        return ObjModelView(objURL: objURL)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}


