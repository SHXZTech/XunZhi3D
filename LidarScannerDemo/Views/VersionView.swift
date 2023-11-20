//
//  VersionView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/17.
//

import SwiftUI

struct VersionView: View {
    var body: some View {
        Section(header: VStack(alignment:.leading){Text("Alpha 0.1").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/); Text("11月10日")
            .font(.footnote)}){
            VStack(alignment:.leading){
                
                Text("测试版首次发布。")
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 30)
        .navigationTitle(NSLocalizedString("Version", comment: "Version"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
}

#Preview {
    VersionView()
}
