//
//  CaptureView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/15.
//

import SwiftUI
import SceneKit
import ARKit


//这个脚本在只显示glb模型的时候根本没有调用，显示obj的时候才调用
struct CaptureView: View {
    var uuid: UUID
    enum ViewMode {
        case model, info
    }
    @ObservedObject var captureService: CaptureViewService
    @Binding var isPresenting: Bool
    @State private var cloudButtonState: CloudButtonState = .wait_upload
    @State private var showDeleteAlert = false
    @State private var showRenameBox = false;
    @State private var newCaptureName = "";
    @State var uploadProgress: Float = 0.0
    @State var downloadProgress: Float = 0.0
    @State var isModelViewerTop: Bool = true;
    @State private var selectedViewMode:ViewMode = ViewMode.model
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State var modelURL: URL?;
    init(uuid: UUID, isPresenting: Binding<Bool>) {
        print("CaptureView initialized")  // 视图初始化时打印
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
                ZStack{
                    content
                        .ignoresSafeArea(.all)
                    VStack{
                        modelInfoPicker
                            .padding(.vertical,15)
                        Spacer()
                    }
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
    
    private var header: some View {
        ZStack {
            HStack{
                Text(captureService.captureModel.captureName ?? NSLocalizedString("untitled", comment: ""))
            }
            HStack {
                Button(action: {
                    self.isPresenting = false
                }, label: {Image(systemName: "chevron.left").foregroundColor(.white)})
                .padding([.horizontal,.leading], 20)
                Spacer()
                Menu {
                    Button(action: {
                        newCaptureName = captureService.captureModel.captureName ?? ""
                        self.showRenameBox = true
                    }) {
                        Label(NSLocalizedString("Rename", comment: ""), systemImage: "pencil").foregroundStyle(.white)
                    }
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
                .alert("Rename", isPresented: $showRenameBox, actions: {
                    TextField("", text: $newCaptureName)
                        .foregroundColor(.black)
                    Button("Sure", action: {captureService.changeCaptureName(newName: newCaptureName)})
                    Button("Cancel", role: .cancel, action: {showRenameBox=false})
                })
            }
            .frame(width: UIScreen.main.bounds.width)
        }
        .onReceive(captureService.$captureModel) { updatedModel in
            cloudButtonState = updatedModel.cloudStatus ?? .wait_upload;
            self.uploadProgress = updatedModel.uploadingProgress
            self.downloadProgress = updatedModel.downloadingProgress
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
            print("modelURL_0000000000 == == == ",self.modelURL)
        }
    }
    
    
    private func CloudButtonAction() {
        captureService.cloudButtonActionHandle()
        switch cloudButtonState {
        case .wait_upload:
            break
        case .uploading:
            self.errorMessage = "云端处理中,请耐心等待"
            self.showErrorAlert = true
            break
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
            break;
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
            break;
            
        }
    }
    
    private var modelInfoPicker: some View {
        VStack {
            Picker("Select View", selection: $selectedViewMode) {
                Text(NSLocalizedString("3D Model", comment: "")).tag(ViewMode.model)
                Text(NSLocalizedString("Info", comment: "")).tag(ViewMode.info)
            }
            .background(Color.gray)
            .cornerRadius(8)
            .pickerStyle(SegmentedPickerStyle())
            .pickerStyle(.segmented)
            .frame(width: 200, height: 50)
            .onChange(of: selectedViewMode) { newValue in
                isModelViewerTop = (newValue == .model)
            }
        }
    }
    
    private var content: some View {
        ZStack {
            Group {
                if captureService.isRawMeshExist() {
                    VStack{
                        Spacer()
                        GeometryReader { geometry in
                            // 打印 modelURL 的值
                            Text("Model URL: \(String(describing: self.$modelURL))")  // 打印 modelURL 的值
                            .onAppear {
                                         print("Model URL is: \(String(describing: self.$modelURL))")
                                       }
                            StateModelViewer(modelURL: self.$modelURL, isModelViewerTop: self.$isModelViewerTop,uuid: self.uuid, width: geometry.size.width, height: geometry.size.height)
                                .cornerRadius(15)
                        }
                        Spacer()
                    }
                } else {
                    Text(NSLocalizedString("Can not load model", comment: ""))
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.6)
                        .onAppear {
                                     print("Model URL obj is: \(String(describing: self.$modelURL))")
                                   }
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
        formatter.allowedUnits = [.useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}


///这个脚本在只显示glb模型的时候根本没有调用，显示obj的时候才调用
struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureView(uuid: UUID(uuidString: "BC587603-DA6B-4CF6-809F-A44E760327FE") ?? UUID(), isPresenting: .constant(true))
            .onAppear {
                            print("CaptureView_Previews is being previewed")
                        }
    }
}

