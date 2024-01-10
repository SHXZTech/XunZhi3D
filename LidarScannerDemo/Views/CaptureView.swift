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
    @ObservedObject var captureService: CaptureViewService
    @Binding var isPresenting: Bool
    @State private var cloudButtonState: CloudButtonState = .wait_upload
    @State private var showDeleteAlert = false
    
    enum ViewMode {
        case model, info
    }
    @State private var selectedViewMode:ViewMode = ViewMode.model
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State var modelURL: URL?;
    
    
    
    init(uuid: UUID, isPresenting: Binding<Bool>) {
        self.uuid = uuid
        self.captureService = CaptureViewService(id_: uuid)
        self._isPresenting = isPresenting
        self.cloudButtonState = .wait_upload
        self.showDeleteAlert = false
        self.selectedViewMode = .model
        self.showErrorAlert = false
        self.errorMessage = ""
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
                CloudButtonView(cloudButtonState: $cloudButtonState, uploadAction: CloudButtonAction)
            }
            HStack {
                Button(action: {
                    self.isPresenting = false
                }, label: {Image(systemName: "chevron.left").foregroundColor(.white)})
                .padding([.horizontal,.leading], 20)
                Spacer()
                Menu {
                    Button(role: .destructive,action: {
                        self.showDeleteAlert = true
                    }) {
                        Label(NSLocalizedString("Delete", comment: ""), systemImage: "trash")
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
        .onReceive(captureService.$captureModel) { updatedModel in
            cloudButtonState = updatedModel.cloudStatus ?? .wait_upload;
        }
        .onReceive(captureService.$updateSyncedModel) { updated in
            if updated {
                if captureService.checkTexturedExist(){
                    cloudButtonState = .downloaded
                }
                if let modelURL_ = captureService.getObjModelURL() {
                    self.modelURL = modelURL_
                }
            }
        }
        .onAppear {
                    if let modelURL_ = captureService.getObjModelURL() {
                        self.modelURL = modelURL_
                    }
                }
        .padding(.vertical, 5)
    }
    
    
    private func CloudButtonAction() {
        switch cloudButtonState {
        case .wait_upload:
            captureService.captureModel.cloudStatus = .uploading
            cloudButtonState = .uploading
            captureService.uploadCapture(completion: { success, message in
                        if success {
                            captureService.captureModel.cloudStatus = .uploaded
                        } else {
                            self.errorMessage = "Upload failed: \(message)"
                            self.showErrorAlert = true
                        }
                    })
        case .uploading:
            self.errorMessage = "云端处理中,请耐心等待"
            self.showErrorAlert = true
        case .uploaded:
            self.errorMessage = "已上传云端,排队处理中"
            self.showErrorAlert = true
        case .wait_process:
            self.errorMessage = "已上传云端,排队处理中"
            self.showErrorAlert = true
        case .processing:
            self.errorMessage = "云端处理中,请耐心等待"
            self.showErrorAlert = true
        case .processed:
            captureService.captureModel.cloudStatus = .downloading
            captureService.downloadTexture(completion: { success, message in
                if success {
                    captureService.captureModel.cloudStatus = .downloaded
                } else {
                    captureService.captureModel.cloudStatus = .processed
                    self.errorMessage = "Download failed: \(message)"
                    self.showErrorAlert = true
                }
            })
        case .downloading:
            self.errorMessage = "下载中，请耐心等待"
            self.showErrorAlert = true
        case .downloaded:
            self.errorMessage = "已同步云端"
            self.showErrorAlert = true
        case .process_failed:
            self.errorMessage = "处理失败,请重新扫描"
            self.showErrorAlert = true
        case .not_created:
            captureService.captureModel.cloudStatus = .uploading
            captureService.createCloudCapture(completion: { success in
                if success {
                    captureService.captureModel.cloudStatus = .uploaded
                    cloudButtonState = .uploading
                    captureService.uploadCapture(completion: { success, message in
                        if success {
                            captureService.captureModel.cloudStatus = .uploaded
                        } else {
                            self.errorMessage = "Upload failed: \(message)"
                            self.showErrorAlert = true
                        }
                    })
                } else {
                    self.errorMessage = "create failed"
                    self.showErrorAlert = true
                }
            })
        }
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
            Group {
                if captureService.isRawMeshExist() {
                    VStack{
                        Spacer()
                        StateModelViewer(modelURL: self.$modelURL, width: UIScreen.main.bounds.width * 1, height: UIScreen.main.bounds.height * 0.8)
                            .cornerRadius(15)
                        Spacer()
                    }
                } else {
                    Text(NSLocalizedString("Can not load model", comment: ""))
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.6)
                }
            }
            .opacity(selectedViewMode == .model ? 1 : 0)
            ModelInfoView(capturemodel_: self.captureService.captureModel)
                .opacity(selectedViewMode == .info ? 1 : 0)
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text(NSLocalizedString("Error", comment: "")), message: Text(errorMessage), dismissButton: .default(Text(NSLocalizedString("OK", comment: ""))))
        }
        .animation(.easeInOut, value: selectedViewMode)
    }

    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB] // or [.useKB, .useGB] depending on the size you expect
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureView(uuid: UUID(uuidString: "BC587603-DA6B-4CF6-809F-A44E760327FE") ?? UUID(), isPresenting: .constant(true))
    }
}

