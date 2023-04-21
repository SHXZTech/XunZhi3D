//
//  RawScanViewer.swift
//  SwitchCameraTutorial
//
//  Created by Tao Hu on 2023/4/21.
//

import SwiftUI
import SceneKit
import ARKit

struct RawScanViewer: View {
    var uuid:UUID
   // var scene:SCNScene
    var body: some View {
        if(isModelExistCheck())
        {
            ModelViewer(modelURL: getModelURL())
        }
        else{
            Text("unable to load file: \(getModelURL().path)")
        }
    }
    
    private func getModelURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let rawMeshURL = documentsDirectory.appendingPathComponent(uuid.uuidString).appendingPathComponent("rawMesh.usd")
        print("rawMeshURL.path for modelview", rawMeshURL.path)
        return rawMeshURL
    }
    
    private func isModelExistCheck() -> Bool {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let rawMeshURL = documentsDirectory.appendingPathComponent(uuid.uuidString).appendingPathComponent("rawMesh.usd")
        print("rawMeshURL check:", rawMeshURL.path)
        print("is rawMeshURL check:",FileManager.default.fileExists(atPath: rawMeshURL.path))
        
 
        do {
            // Attempt to load the scene from the specified URL
            let scene = try SCNScene(url: rawMeshURL)
        } catch let error as NSError {
            // If an error occurs while loading the scene, print the error message and code
            print("Error loading scene: \(error.localizedDescription)")
            print("Error code: \(error.code)")
        }
        print("no error in let scene = try SCNScene(url: rawMeshURL)")
        return FileManager.default.fileExists(atPath: rawMeshURL.path)
    }

}

struct RawScanViewer_Previews: PreviewProvider {
    static var previews: some View {
        RawScanViewer(uuid:UUID())
    }
}
