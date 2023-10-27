//
//  GeoSensorView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/18.
//

import SwiftUI

struct GeoSensorView: View {
    @StateObject var rtkViewModel = RTKViewModel()
    @State private var isShowingRtkSettingPage = false // State to control the presentation of the sheet

    var body: some View {
        
        VStack(alignment: .leading) {
            if rtkViewModel.selectedDevice == nil {
                noRtkConnected()
            }
            Spacer()
        }
        .padding(.top, 20)
        .padding(.leading, 20)
    }

    func noRtkConnected() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "location.slash.fill")
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
                Text("RTK")
                Spacer()
                Button(action: {
                    isShowingRtkSettingPage.toggle()
                }) {
                    Image(systemName: "ellipsis")
                        .frame(width: 20, height: 20)
                }
                .sheet(isPresented: $isShowingRtkSettingPage) {
                    RtkSettingView(viewModel: rtkViewModel, isPresented: $isShowingRtkSettingPage)
                }
            }
            Text("请连接RTK")
                .font(.caption)
                .foregroundColor(.white)
                .padding(.top, 5)
        }
        .frame(maxWidth: 150, maxHeight: 60, alignment: .topLeading)
        .background(Color.gray.opacity(0.6))
        .cornerRadius(10)
    }
}

struct GeoSensorView_Previews: PreviewProvider {
    static var previews: some View {
        GeoSensorView()
    }
}
