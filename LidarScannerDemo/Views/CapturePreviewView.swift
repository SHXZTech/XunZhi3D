//
//  CapturePreviewView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/8.
//

import SwiftUI

struct CapturePreviewView: View {
    var capture: CapturePreviewModel
    var onSelect: (() -> Void)? // Closure to handle selection
    var body: some View {
        VStack(spacing: 0){
            ZStack {
                Rectangle().foregroundColor(.clear)
                AsyncImage(url: capture.previewImageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable() // Make sure the image can be resized
                            .rotationEffect(Angle(degrees: 90))
                            .scaledToFill() // Change this to .scaledToFit()
                    } else if phase.error != nil {
                        ZStack{
                            Color.gray
                            Text(NSLocalizedString("Can not load the image.", comment: "")  )
                        }
                    } else {
                        ZStack{
                            Color.gray
                            Text(NSLocalizedString("Loading...", comment: "loading..."))
                                .font(.footnote)
                        }
                    }
                }
                .frame(width: 180, height: 190)
                .clipped()
            }
            .edgesIgnoringSafeArea(.horizontal)
            HStack{
                Text(capture.dateString.truncated(to: 20))
                    .font(.system(size: 15))
                    .padding(.leading, 5)
                Spacer()
            }
            .padding(.vertical, 5)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(3)
        .frame(width: 180, height: 200)
        .onTapGesture {
            onSelect?() // Call the closure when the view is tapped
        }
    }
}

// MARK: - Preview

struct CapturePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        // Update the preview to use a URL
        CapturePreviewView(capture: CapturePreviewModel(id: UUID(), dateString: "2023-11-07-13:30", date: Date(), previewImageURL: URL(fileURLWithPath: "path/to/example_preview")))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

