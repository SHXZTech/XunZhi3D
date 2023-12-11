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
    @State private var showDeleteAlert = false
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
        if let modelURL = captureService.getObjModelURL() {
            self.modelView = ModelViewer(modelURL: modelURL, width: UIScreen.main.bounds.width * 1, height: UIScreen.main.bounds.height * 0.8)
        } else {
            self.modelView = ModelViewer(modelURL: nil, width: UIScreen.main.bounds.width * 1, height: UIScreen.main.bounds.height * 0.8)
        }
        var capturemodel = self.captureService.captureModel
        if let createDate = self.captureService.getProjectCreationDate(){
            capturemodel.createDate = createDate
        }
        self.modelInfoView = ModelInfoView(capturemodel_: capturemodel)
    }
    
    var body: some View {
        ZStack{
            Color.black
            VStack {
                header
                modelInfoPicker
                content
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
    
    private var header: some View {
        ZStack {
            HStack{
                cloudButton
            }
            HStack {
                Button(action: {
                    self.isPresenting = false
                }, label: {Image(systemName: "chevron.left").foregroundColor(.white)})
                .padding([.horizontal,.leading], 20)
                Spacer()
                Menu {
                    //                    Button(action: {
                    //                        // Action for renaming
                    //                    }) {
                    //                        Label("Rename", systemImage: "pencil")
                    //                    }
                    Button(role: .destructive,action: {
                        self.showDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                .padding([.horizontal, .trailing], 20)
                .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text(NSLocalizedString("Delete Confirmation", comment: "") ),
                        message: Text(NSLocalizedString("Are you sure you want to delete this?", comment: "")),
                        primaryButton: .destructive(Text(NSLocalizedString("Sure", comment: ""))) {
                            captureService.deleteScanFolder()
                            showDeleteAlert = false;
                            isPresenting = false;
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            
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
                    VStack{
                        Spacer()
                        modelView
                            .cornerRadius(15)
                        Spacer()
                    }
                } else {
                    Text(NSLocalizedString("Can not load model", comment: ""))
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.6)
                }
            }
            .opacity(selectedViewMode == .model ? 1 : 0)
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
                Text("上传云端处理")
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
            return NSLocalizedString("Upload", comment: "")
        case .uploading:
            return NSLocalizedString("Uploading", comment: "")
        case .processing:
            return NSLocalizedString("Processing", comment: "")
        case .download:
            return NSLocalizedString("Download", comment: "")
        case .downloading:
            return NSLocalizedString("Downloading", comment: "")
        case .downloaded:
            return NSLocalizedString("Downloaded", comment: "")
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
        CaptureView(uuid: UUID(), isPresenting: .constant(true))
    }
}

