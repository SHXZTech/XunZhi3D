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
import AudioToolbox
import UIKit




struct ScanView: View {
    let uuid: UUID
    @StateObject var lidarMeshViewModel: LidarMeshViewModel
    @StateObject var rtkViewModel: RTKViewModel = RTKViewModel()
    @State private var showTooFastWarning: Bool = false
    @State private var showTooFastWarning_mutex: Bool = false
    @State private var showRTKPoorSignalWarnning: Bool = false
    @State private var showRTKWarning: Bool = false
    @State var scanStatus = "ready"
    @State var navigateToRawScanViewer = false
    @Binding var isPresenting: Bool
    @Binding var isRawScanPresenting: Bool
    
    @State var frameNumber: Int = 0;
    
    
    init(uuid: UUID,isPresenting: Binding<Bool>, isRawScanPresenting: Binding<Bool>) {
        self._isPresenting = isPresenting
        self._isRawScanPresenting = isRawScanPresenting
        self.uuid = uuid
        self._lidarMeshViewModel = StateObject(wrappedValue: LidarMeshViewModel(uuid: uuid))
    }
    
    private func playWarningFeedback() {
        let systemSoundID: SystemSoundID = 1103
        AudioServicesPlayAlertSound(systemSoundID)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    var body: some View {
        VStack {
            ZStack{
                statusText
                    .multilineTextAlignment(.center)
                HStack {
                    Spacer()
                    closeButton
                }
            }
            ZStack{
                ZStack{
                    scanArea
                    VStack{
                        Spacer()
                        if(scanStatus == "scanning"){
                            capturedFrameNumerView
                                .padding(20)
                        }
                        scanButton
                    }
                    .padding(.bottom, 65)
                }
                VStack{
                    if showTooFastWarning {
                        tooFastWarning
                            .padding(.vertical, 200)
                    }
                    Spacer()
                }
            }
        }
        .alert(
            "RTK not connected",
            isPresented: $showRTKWarning,
            presenting:  Text(NSLocalizedString("Do you want to continue scanning without RTK data? This may affect the accuracy of the scan.", comment: ""))
        ) { details in
            Group {
                Button(role: .destructive) {
                    startScan()
                    showRTKWarning = false
                } label: {
                    Text("Scan without RTK")
                }
                Button("Cancel", role: .cancel) {
                    showRTKWarning = false
                }
            }
        } message: { details in
            Text(NSLocalizedString("Do you want to continue scanning without RTK data? This may affect the accuracy of the scan.", comment: ""))
        }
        .alert(
            "RTK Signal is Not Fixed",
            isPresented: $showRTKPoorSignalWarnning,
            presenting: Text(NSLocalizedString("RTK signal is not fixed, move to open area and wait for fixing. Do you wish to proceed without fixed RTK data?", comment: "RTK signal warning"))
        ) { details in
            Group {
                Button(role: .destructive) {
                    startScan()
                    showRTKPoorSignalWarnning = false
                } label: {
                    Text(NSLocalizedString("Scan without fixed Signal", comment: ""))
                }
                Button("Cancel", role: .cancel) {
                    showRTKPoorSignalWarnning = false
                }
            }
        } message: { details in
            Text(NSLocalizedString("RTK signal is not fixed, move to open area and wait for fixing. Do you wish to proceed without fixed RTK data?", comment: "RTK signal warning"))
        }
        .onChange(of: scanStatus) { newStatus in
            if newStatus == "finished" {
                isRawScanPresenting = true
                isPresenting = false
            }
        }
        .onReceive(lidarMeshViewModel.$isTooFast) { isTooFast in
            if (isTooFast) {
                if(!showTooFastWarning_mutex){
                    showTooFastWarning = true
                }
            }
        }
        .onReceive(lidarMeshViewModel.$capturedFrameCount) { capturedFrameCount in
            self.frameNumber = capturedFrameCount
        }
        .onDisappear(){
            rtkViewModel.toDisconnect()
            rtkViewModel.stopTimer()
            rtkViewModel.viewDidDisappear()
        }
        .onAppear(){
            rtkViewModel.viewDidAppear()
        }
    }
    
    private var statusText: some View {
        Text(NSLocalizedString(scanStatus, comment: "ScanStatus"))
    }
    
    private var tooFastWarning: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.yellow)
            Text(NSLocalizedString("slow_down_warnning_message", comment: "slow down"))
                .foregroundColor(.yellow)
                .font(.system(size: 17))
                .bold()
        }
        .padding(10)  // Reduced padding
        .background(Color.gray.opacity(0.6)) // Semi-transparent background
        .cornerRadius(8)
        .frame(maxWidth: 160, maxHeight: 50) // Limit the maximum width of the box
        .onAppear {
            rtkViewModel.viewDidAppear()
            showTooFastWarning_mutex = true
            playWarningFeedback()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showTooFastWarning = false
            }
        }
        .onDisappear{
            showTooFastWarning_mutex = false
        }
    }
    
    private var capturedFrameNumerView: some View {
        Text("\(frameNumber)")
            .foregroundColor(.white)
            .font(.system(size: 20))
            .frame(width: 50, height: 30)
            .background(Color.gray.opacity(0.6))
            .cornerRadius(8)
    }
    
    
    private var closeButton: some View {
        Button(action: {
            lidarMeshViewModel.dropScan()
            isPresenting = false
        }) {
            Image(systemName: "xmark")
                .foregroundColor(.white)
                .font(.system(size: 18))
        }
        .padding(.horizontal, 25)
    }
    
    
    
    private var scanArea: some View {
        ZStack {
            LidarMeshViewContainer(LidarViewModel: lidarMeshViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            GeoSensorView(viewModel: rtkViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(20)
        }
    }
    
    private var scanButton: some View {
        VStack {
            HStack {
                Button(action: scanAction) {
                    if scanStatus == "ready" {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 68, height: 68)
                            Circle()
                                .fill(Color.red)
                                .frame(width: 60, height: 60)
                        }
                    } else {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 68, height: 68)
                            Rectangle()
                                .fill(Color.red)
                                .cornerRadius(5)
                                .frame(width: 30, height: 30)
                        }
                    }
                }
            }
        }
    }
    
    private func scanAction() {
        switch scanStatus{
        case "ready":
            if rtkViewModel.isConnected() {
                if rtkViewModel.isFixed(){
                    startScan()
                }else{
                    showRTKPoorSignalWarnning = true
                }
            } else {
                showRTKWarning = true
            }
        case "scanning":
            finishScan()
            
        default: return
        }
        
        
        
        
    }
    
    private func startScan() {
        scanStatus = "scanning"
        lidarMeshViewModel.startScan()
        rtkViewModel.startRecord(uuid: self.uuid)
        if rtkViewModel.isConnected(){
            lidarMeshViewModel.setRtkConfigInfo(rtk_data: rtkViewModel.rtkData)
        }
    }
    
    private func finishScan() {
        scanStatus = "finished"
        lidarMeshViewModel.pauseScan()
        lidarMeshViewModel.saveScan(uuid: uuid)
        rtkViewModel.toDisconnect()
    }
    
    
}

struct LidarMeshViewContainer: UIViewRepresentable {
    var LidarViewModel: LidarMeshViewModel
    
    func makeUIView(context: Context) -> ARSCNView {
        LidarViewModel.sceneView.automaticallyUpdatesLighting = true
        LidarViewModel.sceneView.delegate = context.coordinator
        let config = ARWorldTrackingConfiguration()
        LidarViewModel.sceneView.session.run(config)
        LidarViewModel.sceneView.addCoaching(active: false)
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
