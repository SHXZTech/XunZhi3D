//
//  GeoSensorView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/18.
//

import SwiftUI

struct GeoSensorView: View {
    @State private var isShowingRtkPage = false
    
    var body: some View {
        VStack {
            HStack {
                Button("RTK") {
                    isShowingRtkPage.toggle()
                }
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 75)
                .background(Color.gray.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(10)
                .sheet(isPresented: $isShowingRtkPage) {
                    RtkSettingView(isPresented: $isShowingRtkPage)
                }

                Spacer() // Pushes the button to the left
            }
            .padding(.leading, 20)
            Spacer() // Pushes the HStack to the top
        }
        .padding(.top, 20)
    }
}




#Preview {
    GeoSensorView()
}
