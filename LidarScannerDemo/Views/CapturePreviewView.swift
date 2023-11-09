//
//  CapturePreviewView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/8.
//

import SwiftUI

struct CapturePreviewView: View {
    var capture: CapturePreviewModel
    var body: some View {
        VStack(spacing: 0){
            Image(capture.previewImageName)
                .resizable() // Make sure the image can be resized
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: 140)
                .cornerRadius(0) // make image bottom 90 angle
                .clipped()
            //Spacer()
            HStack{
                Text(capture.date.truncated(to: 20))
                    .font(.system(size: 15))
                    .padding(.leading, 5)// Make the font a headline font
                Spacer()
            }
            .frame(alignment: .bottom)
            .padding(.vertical, 5)
        }
        .background(Color(.secondarySystemBackground)) // A light gray background
        .cornerRadius(3) // Round the corners of the background
        .frame(width: 200, height: 150)
    }
}

// MARK: - Preview

struct CapturePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        CapturePreviewView(capture: CapturePreviewModel(id: UUID(), date: "2023-11-07-13:30", previewImageName: "example_preview"))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

