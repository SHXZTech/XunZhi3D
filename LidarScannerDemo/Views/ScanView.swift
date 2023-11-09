//
//  ScanView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/4/22.
//

import Foundation
import SceneKit
import ARKit
import SwiftUI


struct ScanView: View{
    let uuid : UUID
    @ObservedObject var lidarMeshViewModel : LidarMeshViewModel
    @ObservedObject var rtkViewModel: RTKViewModel
    @State var scanStatus = "ready"
    @State var navigateToNextView = false
    @State private var isContextMenuVisible = false
    
    var dismissAction: () -> Void
    
    init(dismissAction: @escaping () -> Void) {
        uuid = UUID()
        lidarMeshViewModel = LidarMeshViewModel(uuid: uuid)
        rtkViewModel = RTKViewModel()
        self.dismissAction = dismissAction
    }
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                HStack{
                    Spacer()
                    if(scanStatus == "ready")
                    {
                        Text("READY TO SCAN")
                    }
                    if(scanStatus == "scanning"){
                        Text("SCANING")
                    }
                    if(scanStatus == "finished"){
                        Text("SAVING SCANS")
                        NavigationLink(destination:
                                        RawScanViewer(uuid:uuid)
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                            .ignoresSafeArea(.all)
                                       , isActive: $navigateToNextView) {
                            Text("SAVING SCANS")
                        }
                                       .onAppear {
                                           self.navigateToNextView = true
                                       }
                    }
                    Spacer()
                    Button(action: {
                        dismissAction()
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                    })
                    .padding(.horizontal, 25)
                }
                ZStack{
                    LidarMeshViewContainer(LidarViewModel: lidarMeshViewModel)
                    GeoSensorView(viewModel: rtkViewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(20)
                }
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
        LidarViewModel.sceneView.debugOptions = []
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
