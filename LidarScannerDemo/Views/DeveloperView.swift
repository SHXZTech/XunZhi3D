//
//  DeveloperView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/8.
//

import SwiftUI

struct DeveloperView: View {
    var body: some View {
        VStack{
            HStack{
                Text("Alpha \n 0.1 - thomas")
                    .padding()
                    .frame(alignment: .top)
            Spacer()
            }
            .padding(20)
            Spacer()
        }
        .navigationTitle("开发者")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

#Preview {
    DeveloperView()
}
