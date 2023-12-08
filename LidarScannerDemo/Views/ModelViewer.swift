//
//  ModelViewer.swift
//  scenemesh
//
//  Created by Tao Hu on 2023/4/6.
//

import SwiftUI
import SceneKit



class SceneRendererDelegate: NSObject, ObservableObject, SCNSceneRendererDelegate {
    @Published var isSceneLoaded: Bool = false
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if !isSceneLoaded {
            DispatchQueue.main.async() {
                self.isSceneLoaded = true
            }
        }
    }
}


struct ModelViewer: View {
    var modelURL: URL?
    var width = UIScreen.main.bounds.width
    var height = UIScreen.main.bounds.height
    @ObservedObject var delegate = SceneRendererDelegate()
    
    var body: some View {
        ZStack {
//            if let url = modelURL, let scene = try? SCNScene(url: url) {
                LoadingView()
                    .frame(width: width, height: height)
//                SceneView(scene: scene, options: [.autoenablesDefaultLighting, .allowsCameraControl])
//                    .frame(width: width, height: height)
//                    .scaledToFit()
            ObjModelView(objURL: modelURL!)
//            } else {
//                Text(NSLocalizedString("No model to display", comment: ""))
//            }
        }
    }
}


struct LoadingView: View {
    var body: some View {
        VStack {
            Text(NSLocalizedString("Loading...", comment: "loading..."))
                .font(.headline)
            ProgressView()
        }
    }
}

struct ModelViewer_Previews: PreviewProvider {
    static var previews: some View {
        let modelURL = Bundle.main.url(forResource: "Earth", withExtension: "usdz")!
        return ModelViewer(modelURL: modelURL)
    }
}

