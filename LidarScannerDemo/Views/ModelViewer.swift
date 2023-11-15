//
//  ModelViewer.swift
//  scenemesh
//
//  Created by Tao Hu on 2023/4/6.
//

import SwiftUI
import SceneKit

import SwiftUI
import SceneKit

struct ModelViewer: View {
    var modelURL: URL
    var width = UIScreen.main.bounds.width
    var height = UIScreen.main.bounds.height
    @State private var isLoading = true

    var body: some View {
        ZStack {
            // Display a loading view
            if isLoading {
                LoadingView()
                    .frame(width: width, height: height)
                    .onAppear {
                        // After 3 seconds, hide the loading view
                        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                            self.isLoading = false
                        }
                    }
            }
            // Load SceneView in the background
            if let scene = try? SCNScene(url: modelURL) {
                SceneView(scene: scene, options: [.autoenablesDefaultLighting, .allowsCameraControl])
                    .frame(width: width, height: height)
                    .scaledToFit()
                    .opacity(isLoading ? 0 : 1) // Hide SceneView while loading
            } else {
                Text("Error loading model")
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            Text("Loading...")
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


