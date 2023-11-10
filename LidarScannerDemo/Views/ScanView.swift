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


struct ScanView: View {
    let uuid: UUID //= UUID()
    @StateObject var lidarMeshViewModel: LidarMeshViewModel// = LidarMeshViewModel(uuid: ScanView.uuid)
    @StateObject var rtkViewModel: RTKViewModel = RTKViewModel()
    @State var scanStatus = "ready"
    @State var navigateToRawScanViewer = false
    @Binding var isPresenting: Bool

    init(uuid: UUID,isPresenting: Binding<Bool>) {
        self._isPresenting = isPresenting
        self.uuid = uuid
        self._lidarMeshViewModel = StateObject(wrappedValue: LidarMeshViewModel(uuid: uuid))
         
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                statusText
                Spacer()
                closeButton
            }
            scanArea
            scanButton
        }
        .fullScreenCover(isPresented: $navigateToRawScanViewer) {
            RawScanView(uuid: uuid, isPresenting: $isPresenting)
        }
        .onChange(of: scanStatus) { newStatus in
            if newStatus == "finished" {
                navigateToRawScanViewer = true
            }
        }
    }
    
    private var statusText: some View {
        Text(scanStatus.uppercased())
    }
    
    private var closeButton: some View {
        Button(action: {
            lidarMeshViewModel.dropScan()
            isPresenting = false
        }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.title)
        }
        .padding(.horizontal, 25)
    }
    
    private var scanArea: some View {
        ZStack {
            LidarMeshViewContainer(LidarViewModel: lidarMeshViewModel)
            GeoSensorView(viewModel: rtkViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(20)
        }
    }
    
    private var scanButton: some View {
        VStack {
            HStack {
                Button(action: scanAction) {
                    Image(systemName: scanStatus == "ready" ? "circle.inset.filled" : "stop.circle.fill")
                        .resizable()
                        .foregroundColor(.red)
                        .frame(width: 70, height: 70)
                }
            }
        }
    }
    
    private func scanAction() {
        switch scanStatus {
            case "ready":
                scanStatus = "scanning"
                lidarMeshViewModel.startScan()
            case "scanning":
                scanStatus = "finished"
                lidarMeshViewModel.pauseScan()
                lidarMeshViewModel.saveScan(uuid: uuid)
            default:
                break
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
