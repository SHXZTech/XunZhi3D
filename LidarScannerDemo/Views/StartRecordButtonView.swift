//
//  StartRecordButtonView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/23.
//

import SwiftUI

struct StartRecordButtonView: View {
    var body: some View {
            ZStack {
                // Outer White Ring
                Circle()
                    .stroke(Color.white, lineWidth: 2) // Adjust lineWidth for ring thickness
                    .frame(width: 68, height: 68) // Adjust frame size as needed

                // Inner Red Circle
                Rectangle()
                    .fill(Color.red)
                    .cornerRadius(5)
                    .frame(width: 30, height: 30)
                    // Adjust frame size for the red circle
            }
    }
}

#Preview {
    StartRecordButtonView()
}
