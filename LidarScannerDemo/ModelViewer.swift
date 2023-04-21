//
//  ModelViewer.swift
//  scenemesh
//
//  Created by Tao Hu on 2023/4/6.
//

import SwiftUI
import SceneKit

struct ModelViewer: View {
    var modelURL: URL
    var width = UIScreen.main.bounds.width
    var height = UIScreen.main.bounds.height
    
    var body: some View {
        if let scene = try? SCNScene(url: modelURL) {
            SceneView(scene: scene, options: [.autoenablesDefaultLighting,.allowsCameraControl])
                .frame(width: width , height:  height)
                .scaledToFit()
        } else {
            Text("Error loading model")
        }
    }
}

struct ModelViewer_Previews: PreviewProvider {
    static var previews: some View {
        let modelURL = Bundle.main.url(forResource: "Earth", withExtension: "usdz")!
        return ModelViewer(modelURL: modelURL)
    }
}
