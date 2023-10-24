//
//  RtkSettingView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/19.
//
import SwiftUI

struct RtkSettingView: View {
    @ObservedObject var viewModel: RTKViewModel
    @ObservedObject var ntripModel: NtripConfigViewModel
    
    init(viewModel: RTKViewModel = RTKViewModel(), ntripModel: NtripConfigViewModel = NtripConfigViewModel()) {
        self.viewModel = viewModel
        self.ntripModel = ntripModel
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // RTK Data Section
            VStack(alignment: .leading, spacing: 10) {
                List(selection: $viewModel.selectedDevice) {
                    ForEach(viewModel.rtkData.list, id: \.self) { device in
                        Text(device)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(viewModel.selectedDevice == device ? Color.yellow : Color.clear)
                            .tag(device) // This is necessary for selection to work properly
                            .onAppear {
                                if viewModel.selectedDevice == device {
                                    if let index = viewModel.rtkData.list.firstIndex(of: device) {
                                        viewModel.toConnect(index: index)
                                        ntripModel.toConnectDiff()
                                    }
                                }
                            }
                            .onDisappear {
                                if viewModel.selectedDevice == device {
                                    viewModel.toDisconnect()
                                }
                            }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .padding()
            
            GroupBox(label: Text("RTK Data")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Device Name: \(viewModel.rtkData.deviceName)")
                    Text("Electricity: \(viewModel.rtkData.electricity)%")
                    Text("Diff Status: \(viewModel.rtkData.diffStatus)")
                    Text("Diff Delay: \(viewModel.rtkData.diffDelay)s")
                    Text("Longitude: \(viewModel.rtkData.longitude)")
                    Text("Latitude: \(viewModel.rtkData.latitude)")
                }
                .padding()
            }
            
            GroupBox(label: Text("Config Data")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ntrip IP: \(ntripModel.ntripConfigModel.ip)")
                    Text("Ntrip Port: \(ntripModel.ntripConfigModel.port)")
                    Text("Ntrip Account: \(ntripModel.ntripConfigModel.account)")
                    Text("Ntrip Password: \(ntripModel.ntripConfigModel.password)")
                    Text("Mount Point: \(ntripModel.ntripConfigModel.currentMountPoint)")
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
