//
//  ContentView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/4/21.
//

import SwiftUI
import RealityKit
import SceneKit
import ARKit

struct ContentView : View {
    @ObservedObject var lidarMeshViewModel : LidarMeshViewModel = LidarMeshViewModel()
    @State var scanStatus = "ready"
    let uuid = UUID()
    @State var navigateToNextView = false
    var body: some View {
        NavigationView {
            VStack {
                if(scanStatus == "ready")
                {
                    Text("READY TO SCAN")
                }
                if(scanStatus == "scanning"){
                    Text("SCANING")
                }
                if(scanStatus == "finished"){
                    Text("SAVING SCANS")
                    NavigationLink(destination: RawScanViewer(uuid:uuid), isActive: $navigateToNextView) {
                        Text("SAVING SCANS")
                    }
                    .onAppear {
                        self.navigateToNextView = true
                    }
                }
                LidarMeshViewContainer(LidarViewModel: lidarMeshViewModel).edgesIgnoringSafeArea(.all)
                VStack{
                    HStack{
                        Button(action: {
                            if(scanStatus == "ready"){
                                scanStatus = "scanning"
                                lidarMeshViewModel.startScan()
                            }else{
                                if(scanStatus == "scanning"){
                                    scanStatus = "finished"
                                    lidarMeshViewModel.pauseScan()
                                    lidarMeshViewModel.saveScan(uuid: uuid)
                                }
                            }
                        }, label: {
                            if(scanStatus == "ready")
                            {
                                Image(systemName: "circle.inset.filled")
                                    .resizable()
                                    .foregroundColor(.red)
                            }
                            if(scanStatus == "scanning"){
                                Image(systemName: "stop.circle.fill")
                                    .resizable()
                                    .foregroundColor(.red)
                            }
                        })
                        .frame(width: 70, height: 70)
                    }
                }
                
                
            }
        }
    }
}


struct LidarMeshViewContainer: UIViewRepresentable {
    var LidarViewModel: LidarMeshViewModel
    
    func makeUIView(context: Context) -> ARSCNView {
        LidarViewModel.sceneView.automaticallyUpdatesLighting = true
        LidarViewModel.sceneView.delegate = context.coordinator
        let config = ARWorldTrackingConfiguration()
        LidarViewModel.sceneView.session.run(config)
        LidarViewModel.sceneView.addCoaching()
        LidarViewModel.sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints, SCNDebugOptions.showCameras]
        return LidarViewModel.sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        let parent : LidarMeshViewContainer
        
        init(_ parent: LidarMeshViewContainer) {
            self.parent = parent
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let meshAnchor = anchor as? ARMeshAnchor else { return }
            node.geometry = SCNGeometry.makeFromMeshAnchor(meshAnchor)
        }
    }
    
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
