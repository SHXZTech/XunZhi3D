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
            // Load image from URL
            AsyncImage(url: capture.previewImageURL) { image in
                image.resizable() // Make sure the image can be resized
            } placeholder: {
                Color.gray // Show a placeholder when the image is loading
            }
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: 140)
            .cornerRadius(0) // Make image bottom 90 angle
            .clipped()
            
            HStack{
                Text(capture.dateString.truncated(to: 20))
                    .font(.system(size: 15))
                    .padding(.leading, 5) // Make the font a headline font
                Spacer()
            }
            .frame(alignment: .bottom)
            .padding(.vertical, 5)
        }
        .background(Color(.secondarySystemBackground)) // A light gray background
        .cornerRadius(3) // Round the corners of the background
        .frame(width: 200, height: 150)
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

