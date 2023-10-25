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
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.rtkData.list, id: \.self) { device in
                        Text(device)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .padding()
                            .background(viewModel.selectedDevice == device ? Color.yellow : Color.clear)
                            .cornerRadius(5)
                            .onTapGesture {
                                if viewModel.selectedDevice == device {
                                    print("Cancel selection")
                                    viewModel.toDisconnect()
                                    viewModel.selectedDevice = nil
                                } else {
                                    print("Selection or switch")
                                    print("Device:", device)
                                    print("Device list:", viewModel.rtkData.list)
                                    if let index = viewModel.rtkData.list.firstIndex(of: device) {
                                        print("Connecting to index:", index)
                                        viewModel.toDisconnect()
                                        viewModel.toConnect(index: index)
                                        //ntripModel.toConnectDiff()
                                        //ntripModel.getMountPoint()
                                    }
                                    viewModel.selectedDevice = device
                                }
                            }
                    }
                }
                .padding()
            }
            .padding(.horizontal)
            
            GroupBox(label: Text("RTK Data")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Device Name: \(viewModel.rtkData.deviceName)")
                    Text("Electricity: \(viewModel.rtkData.electricity)")
                    Text("Diff Status: \(viewModel.rtkData.diffStatus)")
                    Text("Longitude: \(viewModel.rtkData.longitude)")
                    Text("Latitude: \(viewModel.rtkData.latitude)")
                    Text("Height: \(viewModel.rtkData.height)")
                    Text("HorizontalAccuracy: \(viewModel.rtkData.horizontalAccuracy)")
                    Text("verticalAccuracy: \(viewModel.rtkData.verticalAccuracy)")
                    Text("Satellite Num: \(viewModel.rtkData.satelliteCount)")
                    
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
                    Button("Verify Ntrip"){ ntripModel.getMountPoint()}
                    Button("Login Ntrip"){ntripModel.toConnectDiff()}
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

