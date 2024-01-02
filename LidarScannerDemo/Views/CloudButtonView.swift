//
//  CloudButtonView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/12/28.
//

import SwiftUI



struct CloudButtonView: View {
    @Binding var cloudButtonState: CloudButtonState
    var uploadAction: () -> Void
    var body: some View {
            Button(action: uploadAction) {
                VStack(alignment: .center) {
                    HStack {
                        if cloudButtonState == .downloading || cloudButtonState == .uploading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: imageForState(cloudButtonState))
                                .foregroundColor(.white)
                        }
                        Text(textForState(cloudButtonState))
                            .foregroundStyle(.white)
                    }
                    Text(textForStateMention(cloudButtonState))
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 140, height: 50)
                .background(colorForButton(cloudButtonState))
                .cornerRadius(15.0)
            }
        }
    private func colorForButton(_ state: CloudButtonState)-> Color{
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
    
    private func textForStateMention(_ state: CloudButtonState)-> String{
        switch state {
        case .wait_upload, .not_created:
            return NSLocalizedString("Not Upload yet", comment: "")
        case .uploading:
            return NSLocalizedString("Uploading to cloud", comment: "")
        case .uploaded, .wait_process, .processing:
            return NSLocalizedString("Cloud processing", comment: "")
        case .processed:
            return NSLocalizedString("Cloud processed", comment: "")
        case .downloading:
            return NSLocalizedString("Downloading", comment: "")
        case .downloaded:
            return NSLocalizedString("Sync cloud", comment: "")
        case .process_failed:
            return NSLocalizedString("Processed failed", comment: "")
        }
    }
    
    private func textForState(_ state: CloudButtonState) -> String {
        switch state {
        case .wait_upload, .not_created:
            return NSLocalizedString("Upload", comment: "")
        case .uploading:
            return NSLocalizedString("Uploading", comment: "")
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
    
    private func imageForState(_ state: CloudButtonState) -> String {
        switch state {
        case .wait_upload, .not_created:
            return "icloud.and.arrow.up"
        case .uploaded, .wait_process, .processing:
            return "arrow.triangle.2.circlepath.icloud"
        case .processed, .downloading:
            return "icloud.and.arrow.down"
        case .downloaded:
            return "checkmark.icloud"
        case .uploading:
            return "icloud.and.arrow.up.fill"
        case .process_failed:
            return "xmark.icloud.fill"
        }
    }
}


struct CloudButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CloudButtonView(cloudButtonState: .constant(.uploading), uploadAction: {
        })
        .previewLayout(.sizeThatFits) // Optionally, set a layout size for the preview
    }
}

