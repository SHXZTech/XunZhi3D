//
//  RtkSettingView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/19.
//
import SwiftUI

struct RtkSettingView: View {
    @ObservedObject var viewModel = RTKViewModel()
    
    
    var body: some View {
        VStack(spacing: 20) {
            // RTK Data Section
            VStack(alignment: .leading, spacing: 10) {
                List(viewModel.deviceList, id: \.self, selection: $viewModel.selectedDevice) { device in
                    Text(device)
                        .frame(maxWidth: .infinity, minHeight: 44)  // Take up full width of List and set minimum height
                        .background(viewModel.selectedDevice == device ? Color.yellow : Color.clear)  // Highlight background
                        .onTapGesture {
                            // Toggle behavior: If the device is already selected, disconnect and deselect.
                            if viewModel.selectedDevice == device {
                                viewModel.toDisconnect()
                                viewModel.selectedDevice = nil
                            } else {
                                if let index = viewModel.deviceList.firstIndex(of: device) {
                                    viewModel.toConnect(index: index)
                                }
                                viewModel.selectedDevice = device
                            }
                        }
                }
            }
            .padding()
            
            GroupBox(label: Text("RTK Data")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Device Name: \(viewModel.deviceName)")
                    Text("Electricity: \(viewModel.electricity)")
                    Text("Diff Status: \(viewModel.diffStatus)")
                    Text("Diff Delay: \(viewModel.diffDelay)")
                    Text("Longitude: \(viewModel.longitude)")
                    Text("Latitude: \(viewModel.latitude)")
                }
                .padding()
            }
        }
        .padding()
        .onAppear {
            viewModel.startListening()
        }
    }
}

struct RtkSettingView_Previews: PreviewProvider {
    static var previews: some View {
        RtkSettingView()
    }
}
