//
//  MainTagView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/7.
//

import SwiftUI

struct MainTagView: View {
    var body: some View {
        NavigationStack {
            ZStack{
                Color(red: 0.05, green: 0.05, blue: 0.05, opacity: 1.0)
                VStack(spacing: 0) {
                    Text("Home Content")
                }
            }
            .navigationTitle("SiteSight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black,for: .navigationBar, .tabBar)
        }
    }
}

#Preview {
    MainTagView()
}
