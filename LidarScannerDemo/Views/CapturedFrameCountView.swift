//
//  CapturedFrameCountView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/23.
//

import SwiftUI

struct CapturedFrameCountView: View {
    var body: some View {
        VStack{
            Text("\(0)")
                .foregroundColor(.white)
                .font(.system(size: 20))
        }
                .frame(width: 50, height: 30)
                .background(Color.gray.opacity(0.6))
                .cornerRadius(8)
                
                 // Limit the maximum width of the box
        //
    }
}


#Preview {
    CapturedFrameCountView()
}
