//
//  RtkSettingView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/19.
//
import SwiftUI

struct RtkSettingView: View {
    @ObservedObject var viewModel = RTKViewModel()
    @State var msg = "ready"
    
    var body: some View {
        VStack(spacing: 20) {
            // RTK Data Section
            GroupBox(label: Text("RTK Data")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Device Name: \(viewModel.deviceName)")
                    Text("Electricity: \(viewModel.electricity)")
                    Text("Diff Status: \(viewModel.diffStatus)")
                    Text("Diff Delay: \(viewModel.diffDelay)")
                    Text("Longitude: \(viewModel.longitude)")
                    Text("Latitude: \(viewModel.latitude)")
                    Text("message:\(msg)")
                }
                .padding()
            }
            
            // Buttons Section
            VStack(spacing: 15) {
                Button("Start Listening") {
                    viewModel.startListening()
                }
                .frame(width: 200, height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("End Listening") {
                    viewModel.endListening()
                }
                .frame(width: 200, height: 50)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Search") {
                    viewModel.toSearch()
                    msg = "search toggle"
                    print("debug search toggle")
                }
                .frame(width: 200, height: 50)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Connect") {
                    viewModel.toConnect(index: 0)
                    msg = "search toggle"
                    print("debug search toggle")
                }
                .frame(width: 200, height: 50)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Disconnect") {
                    viewModel.toDisconnect()
                }
                .frame(width: 200, height: 50)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct RtkSettingView_Previews: PreviewProvider {
    static var previews: some View {
        RtkSettingView()
    }
}
