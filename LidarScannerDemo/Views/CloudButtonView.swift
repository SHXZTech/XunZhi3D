//
//  CloudButtonView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/12/28.
//

import SwiftUI



struct CloudButtonView: View {
    @Binding var cloudButtonState: CloudButtonState
    @Binding var uploadProgress: Float
    @Binding var downloadProgress: Float
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
                Text(textForStateMention(cloudButtonState, upload_progress: uploadProgress, download_progress: downloadProgress))
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 140, height: 50)
            .background(
                ZStack {
                    if cloudButtonState == .uploading {
                        ProgressBackgroundView(progress: uploadProgress)
                    } else {
                        if cloudButtonState == .downloading{
                            ProgressBackgroundView(progress: downloadProgress)
                        }else{
                            colorForButton(cloudButtonState)}
                    }
                }
            )
            .cornerRadius(15.0)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 0.5)  // You can adjust the line width
                    .foregroundColor(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0)) // And the color of the border
            )
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
    
    private func textForStateMention(_ state: CloudButtonState, upload_progress: Float, download_progress: Float)-> String{
        let formatted_upload_progress = String(format: "%.0f%%", upload_progress * 100) // Format
        let formatted_download_progress = String(format: "%.0f%%", download_progress * 100) // Format
        switch state {
        case .wait_upload, .not_created:
            return NSLocalizedString("Not Upload yet", comment: "")
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
        CloudButtonView(cloudButtonState: .constant(.uploading), uploadProgress: .constant(0.5), downloadProgress: .constant(0.4),uploadAction: {
        })
        .previewLayout(.sizeThatFits) // Optionally, set a layout size for the preview
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCornerCustomed(radius: radius, corners: corners) )
    }
}

struct RoundedCornerCustomed: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


