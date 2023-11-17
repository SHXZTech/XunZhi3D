//
//  CaptureView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/15.
//

import SwiftUI
import SceneKit
import ARKit



struct CaptureView: View {
    var uuid: UUID
    var captureService: CaptureViewService
    @Binding var isPresenting: Bool
    @State private var cloudButtonState: CloudButtonState = .upload
    
    private var modelView: ModelViewer
    private var modelInfoView: ModelInfoView
    
    enum ViewMode {
        case model, info
    }
    
    @State private var selectedViewMode:ViewMode = ViewMode.info
    
    
    init(uuid: UUID, isPresenting: Binding<Bool>) {
        self.uuid = uuid
        self.captureService = CaptureViewService(id_: uuid)
        self._isPresenting = isPresenting
        self.modelView = ModelViewer(modelURL: captureService.getRawMeshURL(), height: UIScreen.main.bounds.height * 0.5)
        self.modelInfoView = ModelInfoView()
    }
    
    var body: some View {
        ZStack{
            Color.black
            VStack {
                header
                modelInfoPicker
                Spacer()
                content
                Spacer()
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
    
    private var header: some View {
        ZStack {
            HStack {
                Button(action: {
                    self.isPresenting = false
                }, label: {Image(systemName: "chevron.left").foregroundColor(.white)})
                .padding([.horizontal,.leading], 5)
                Spacer()
                Button(action: {
                }, label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                })
            }
            .padding(.horizontal, 5)
            HStack{
                cloudButton
            }
        }
        .padding(.vertical, 5)
    }
    
    private var modelInfoPicker: some View {
        VStack {
            // Segmented Picker for switching views
            Picker("Select View", selection: $selectedViewMode) {
                Text(NSLocalizedString("3D Model", comment: "")).tag(ViewMode.model)
                Text(NSLocalizedString("Info", comment: "")).tag(ViewMode.info)
            }
            .pickerStyle(.segmented)
            .frame(width: 200, height: 40)
        }
    }
    
    private var content: some View {
        ZStack {
            // Model Viewer View
            Group {
                if captureService.isRawMeshExist() {
                    modelView
                } else {
                    Text(NSLocalizedString("Can not load model", comment: ""))
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5)
                }
            }
            .opacity(selectedViewMode == .model ? 1 : 0)
            
            // Model Info View
            modelInfoView
                .opacity(selectedViewMode == .info ? 1 : 0)
        }
        .animation(.easeInOut, value: selectedViewMode)
    }
    
    enum CloudButtonState {
        case upload, uploading, processing, download, downloading, downloaded
    }
    
    private var cloudButton: some View {
        Button(action: {
            // Define actions for each state here
        }) {
            VStack(alignment: .center) {
                HStack {
                    Image(systemName: imageForState(cloudButtonState))
                        .foregroundColor(.white)
                    Text(textForState(cloudButtonState))
                        .foregroundStyle(.white)
                }
                Text("请上传云端处理")
                    .font(.system(size: 10))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 120, height: 40)
            .background(Color.blue)
            .cornerRadius(15.0)
        }
    }
    
    private func textForState(_ state: CloudButtonState) -> String {
        switch state {
        case .upload:
            return "Upload"
        case .uploading:
            return "Uploading"
        case .processing:
            return "Processing"
        case .download:
            return "Download"
        case .downloading:
            return "Downloading"
        case .downloaded:
            return "Downloaded"
        }
    }
    
    private func imageForState(_ state: CloudButtonState) -> String {
        switch state {
        case .upload, .uploading:
            return "icloud.and.arrow.up"
        case .processing:
            return "arrow.triangle.2.circlepath.icloud"
        case .download, .downloading:
            return "icloud.and.arrow.down"
        case .downloaded:
            return "checkmark.icloud"
        }
    }
    
    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB] // or [.useKB, .useGB] depending on the size you expect
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// Update your preview provider to pass a constant binding.
struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        // Use constant binding for previews
        CaptureView(uuid: UUID(), isPresenting: .constant(true))
    }
}

