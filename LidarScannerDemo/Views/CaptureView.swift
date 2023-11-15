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
    @State private var showingExitConfirmation = false
    @State private var cloudButtonState: CloudButtonState = .upload

    
    init(uuid: UUID, isPresenting: Binding<Bool>) {
        self.uuid = uuid
        self.captureService = CaptureViewService(id_: uuid)
        self._isPresenting = isPresenting
    }
    
    var body: some View {
        VStack {
            header
            Spacer()
            content
            Spacer()
        }
    }
    
    private var header: some View {
        ZStack {
            HStack {
                Spacer()
                Button(action: {
                }, label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                })
                .padding(.horizontal, 25)
            }
            HStack{
                cloudButton
            }
        }
        .padding(.vertical, 10)
    }
    
    
    private var content: some View {
        Group {
            if captureService.isRawMeshExist() {
                ModelViewer(modelURL: captureService.getRawMeshURL(), height: UIScreen.main.bounds.height*0.5)
            } else {
                Text(NSLocalizedString("Can not load model", comment: ""))
                    .frame(width: UIScreen.main.bounds.width, height: .infinity)
            }
        }
    }
    
    enum CloudButtonState {
        case upload, uploading, processing, download, downloading, downloaded
    }

    
    private var cloudButton: some View {
        Button(action: {
            // Define actions for each state here
        }) {
            VStack(alignment: .center) {
                VStack{
                    HStack {
                        Image(systemName: imageForState(cloudButtonState))
                            .foregroundColor(.white)
                        Text(textForState(cloudButtonState))
                            .foregroundStyle(.white)
                    }
                    Text("\(formatBytes(captureService.getProjectSize()))")
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .frame(width: 200, height: 60)
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

