//
//  testView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/7.
//

import SwiftUI

struct testView: View {
    var body: some View {
            NavigationStack {
                List {
                    Text("Hello, SwiftUI!")
                }
                .navigationTitle("Navigation Title")
                .toolbarBackground(

                    // 1
                    Color.pink,
                    // 2
                    for: .navigationBar)
            }
        }
}

#Preview {
    testView()
}
