//
//  UploadButtonView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/12/28.
//

import SwiftUI



struct UploadButtonView: View {
    @Binding var cloudButtonState: CloudButtonState
    @Binding var uploadProgress: Float
    @Binding var downloadProgress: Float
    @State var max_upload_progress: Float = -1.0
    @State var max_download_progress: Float = -1.0
    var uploadAction: () -> Void
    var body: some View {
        Button(action: uploadAction) {
            VStack(alignment: .center) {
                HStack {
                    Text(textForStateMention(cloudButtonState, upload_progress: max_upload_progress,download_progress: max_download_progress))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 400, height: 50)
            .background(
                ZStack {
                    if cloudButtonState == .uploading {
                        ProgressBackgroundView(progress: max_upload_progress)
                    } else {
                        if cloudButtonState == .downloading{
                            ProgressBackgroundView(progress: max_download_progress)
                        }else{
                            colorForUploadButton(cloudButtonState)}
                    }
                }
            )
            .cornerRadius(15.0)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 1)  // You can adjust the line width
                    .foregroundColor(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0)) // And the color of the border
            )
        }
        .onChange(of: uploadProgress) { newValue in
                   max_upload_progress = max(max_upload_progress, newValue)
               }
        .onChange(of: downloadProgress) { newValue in
            max_download_progress = max(max_download_progress, newValue)
        }
    }
    
    private func ProgressBackgroundView(progress: Float) -> some View {
        GeometryReader { geometry in
            Rectangle()
                .frame(width: CGFloat(progress) * geometry.size.width, height: geometry.size.height)
                .foregroundColor(Color.blue) // Adjust the color and opacity as needed
                .animation(.linear, value: progress)
                .cornerRadius(15.0, corners: [.topLeft, .bottomLeft])
        }
    }
    
    private func colorForUploadButton(_ state: CloudButtonState)-> Color{
        switch state{
        case .wait_upload, .not_created:
            return Color.blue
        case .uploading:
            return Color.blue
        case .uploaded, .wait_process, .processing:
            return Color.blue
        case .processed:
            return Color.blue
        case .downloading:
            return Color.blue
        case .downloaded:
            return Color.green
        case .process_failed:
            return Color.red
        }
    }
    
    private func textForStateMention(_ state: CloudButtonState, upload_progress: Float, download_progress: Float)-> String{
        let formatted_upload_progress = String(format: "%.0f%%", upload_progress * 100) // Format
        let formatted_download_progress = String(format: "%.0f%%", download_progress * 100) // Format
        switch state {
        case .wait_upload, .not_created:
            return NSLocalizedString("Upload & Process", comment: "")
        case .uploading:
            return NSLocalizedString("Uploading to cloud", comment: "") + " \(formatted_upload_progress)"
        case .uploaded, .wait_process, .processing:
            return NSLocalizedString("Cloud processing", comment: "")
        case .processed:
            return NSLocalizedString("Cloud processed", comment: "")
        case .downloading:
            return NSLocalizedString("Downloading", comment: "") + " \(formatted_download_progress)"
        case .downloaded:
            return NSLocalizedString("Sync cloud", comment: "")
        case .process_failed:
            return NSLocalizedString("Processed failed", comment: "")
        }
    }
    
    private func textForUploadState(_ state: CloudButtonState, progress: Float) -> String {
        switch state {
        case .wait_upload, .not_created:
            return NSLocalizedString("Upload", comment: "")
        case .uploading:
            return NSLocalizedString("Uploading", comment: "")+" \(progress)"
        case .uploaded, .wait_process, .processing:
            return NSLocalizedString("Processing", comment: "")
        case .processed:
            return NSLocalizedString("Processed", comment: "")
        case .downloading:
            return NSLocalizedString("Downloading", comment: "")
        case .downloaded:
            return NSLocalizedString("Synced", comment: "")
        case .process_failed:
            return NSLocalizedString("Process failed", comment: "")
        }
    }
}
