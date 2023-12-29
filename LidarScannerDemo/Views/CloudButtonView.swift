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
                    Image(systemName: imageForState(cloudButtonState))
                        .foregroundColor(.white)
                    Text(textForState(cloudButtonState))
                        .foregroundStyle(.white)
                }
                Text(textForStateMention(cloudButtonState))
                    .font(.system(size: 10))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 120, height: 40)
            .background(Color.blue)
            .cornerRadius(15.0)
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
            return NSLocalizedString("Downloaded", comment: "")
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
            print("Upload action triggered")
        })
        .previewLayout(.sizeThatFits) // Optionally, set a layout size for the preview
    }
}

