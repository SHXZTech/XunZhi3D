//
//  RawScanViewer.swift
//  SiteSight
//
//  Created by Tao Hu on 2023/4/21.
//

import SwiftUI
import SceneKit
import ARKit

struct RawScanView: View {
    var uuid: UUID
    var rawScanManager: RawScanManager
    var capture_service: CaptureViewService
    @State var uploadProgress: Float = 0.0
    @State var downloadProgress: Float = 0.0
    @Binding var isPresenting: Bool
    
    @State private var uploadButtonState: CaptureState = .wait_upload
    @State private var showingExitConfirmation = false
    
    init(uuid: UUID, isPresenting: Binding<Bool>) {
        self.uuid = uuid
        self.rawScanManager = RawScanManager(uuid: uuid)
        self.capture_service = CaptureViewService(id_: uuid)
        self._isPresenting = isPresenting
    }
    
    var body: some View {
        VStack {
            header
            Spacer()
            content
            Spacer()
            controls
                .padding(.vertical, 20)
        }
    }
    
    private var header: some View {
        ZStack {
            HStack {
                returnButton
                    .padding(.horizontal, 15)
                Spacer()
                menuButton
                    .padding(.horizontal, 15)
            }
            Text(NSLocalizedString("Draft", comment: ""))
                .multilineTextAlignment(.center)
                .font(.system(size: 20))
        }
        .padding(.vertical, 10)
    }
    
    private var returnButton: some View{
        Button(action: {
            self.isPresenting = false
        }, label: {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
                .font(.system(size: 18))
        })
    }
    
    private var menuButton: some View{
        Menu{
            Button(role: .destructive,action: {
                self.showingExitConfirmation = true
            }) {
                Label(NSLocalizedString("Delete", comment: ""), systemImage: "trash")
                    .foregroundStyle(.red)
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .imageScale(.large)
                .foregroundColor(.white)
        }
        .animation(.easeInOut(duration: 0.1), value: showingExitConfirmation)
        .actionSheet(isPresented: $showingExitConfirmation) {
            ActionSheet(
                title: Text(NSLocalizedString("Confirm exit?", comment: "")),
                message: Text(NSLocalizedString("Deleting the draft will delete all collected data", comment: "")),
                buttons: [
                    .destructive(Text(NSLocalizedString("Delete draft", comment: ""))) {
                        rawScanManager.deleteProjectFolder()
                        capture_service.deleteScanFolder()
                        isPresenting = false
                    },
                    .default(Text(NSLocalizedString("Save draft", comment: ""))) {
                        isPresenting = false
                    },
                    .cancel()
                ]
            )
        }
    }
    
    private var content: some View {
        Group {
            if rawScanManager.isRawMeshExist() {
                ModelViewer(modelURL: rawScanManager.getRawObjURL(), height: UIScreen.main.bounds.height*0.6)
            } else {
                Text(NSLocalizedString("Can not load model", comment: ""))
                    .frame(width: UIScreen.main.bounds.width, height: .infinity)
            }
        }
    }
    
    private var controls: some View {
        VStack {
            UploadButtonView(cloudButtonState: $uploadButtonState, uploadProgress: $uploadProgress, downloadProgress: $downloadProgress, uploadAction: CloudButtonAction)
            HStack() {
                Text(NSLocalizedString("Image count", comment: "") + ": \(rawScanManager.raw_scan_model.frameCount)")
                    .font(.footnote)
                Spacer()
                Text(NSLocalizedString("Estimated time", comment: "") + formatTime(seconds: rawScanManager.raw_scan_model.estimatedProcessingTime))
                    .font(.footnote)
            }
            .padding(.horizontal,40)
        }
        .onReceive(rawScanManager.$raw_scan_model) { updatedModel in
            uploadButtonState = updatedModel.cloudStatus ?? .wait_upload;
            self.uploadProgress = updatedModel.uploadingProgress
            print("updatedModel.uploadingProgress = ", updatedModel.uploadingProgress)
        }
    }
    
    private func CloudButtonAction() {
        rawScanManager.checkstatusAndUpload()
    }
    
    func formatTime(seconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        if seconds >= 3600 { // 3600 seconds in an hour
            formatter.allowedUnits = [.hour, .minute]
        } else {
            formatter.allowedUnits = [.minute]
        }
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(seconds)) ?? "0"
    }
}

// Update your preview provider to pass a constant binding.
struct RawScanViewer_Previews: PreviewProvider {
    static var previews: some View {
        RawScanView(uuid: UUID(), isPresenting: .constant(true))
    }
}
