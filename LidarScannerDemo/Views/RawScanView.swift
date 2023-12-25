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
    var cloud_service: CloudService
    @Binding var isPresenting: Bool
    @State private var showingExitConfirmation = false
    
    init(uuid: UUID, isPresenting: Binding<Bool>) {
        self.uuid = uuid
        self.rawScanManager = RawScanManager(uuid: uuid)
        self._isPresenting = isPresenting
        self.cloud_service = CloudService()
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
                Spacer()
                Button(action: {
                    self.showingExitConfirmation = true
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                })
                .padding(.horizontal, 25)
                .actionSheet(isPresented: $showingExitConfirmation) {
                    ActionSheet(
                        title: Text(NSLocalizedString("Confirm exit?", comment: "")),
                        message: Text(NSLocalizedString("Deleting the draft will delete all collected data", comment: "")),
                        buttons: [
                            .destructive(Text(NSLocalizedString("Delete draft", comment: ""))) {
                                rawScanManager.deleteProjectFolder()
                                isPresenting = false
                            },
                            .default(Text(NSLocalizedString("Save draft", comment: ""))) {
                                rawScanManager.moveScanFromCacheToDist()
                                isPresenting = false
                            },
                            .cancel()
                        ]
                    )
                }
            }
            Text(NSLocalizedString("Draft", comment: ""))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 10)
    }
    
    
    private var content: some View {
        Group {
            if rawScanManager.isRawMeshExist() {
                ModelViewer(modelURL: rawScanManager.getRawObjURL(), height: UIScreen.main.bounds.height*0.5)
            } else {
                Text(NSLocalizedString("Can not load model", comment: ""))
                    .frame(width: UIScreen.main.bounds.width, height: .infinity)
            }
        }
    }
    
    
    private var controls: some View {
        VStack {
            Button(NSLocalizedString("Upload & Process", comment: "")) {
                rawScanManager.moveScanFromCacheToDist()
                isPresenting = false
                //Handle upload and process action
                // create capture
                cloud_service.createCapture(uuid: uuid) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let response):
                                print("Capture created successfully: \(response)")
                            case .failure(let error):
                                print("Error creating capture: \(error)")
                            }
                        }
                    }
                // upload
                
                
            }
            .frame(width: 360, height: 54, alignment: .center)
            .background(Color.blue)
            .foregroundColor(Color.white)
            .cornerRadius(13)
            .frame(width: 360, height: 54, alignment: .center)
            .background(Color.red)
            .foregroundColor(Color.white)
            .cornerRadius(13)
            
            HStack() {
                Text(NSLocalizedString("Image count", comment: "") + ": \(rawScanManager.raw_scan_model.frameCount)")
                    .font(.footnote)
                Spacer()
                Text(NSLocalizedString("Estimated time", comment: "") + formatTime(seconds: rawScanManager.raw_scan_model.estimatedProcessingTime))
                    .font(.footnote)
                // Future button to upload to cloud
            }
            .padding(.horizontal,40)
        }
    }
    
    private func formatTime(seconds: Int) -> String {
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
