import SwiftUI

struct RtkSettingView: View {
    @ObservedObject var viewModel: RTKViewModel
    
    
    init(viewModel: RTKViewModel = RTKViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                GroupBox(label: Text("RTK Device")) {
                    VStack(spacing: 20) {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(viewModel.rtkData.list, id: \.self) { device in
                                Text(device)
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                    .padding(10)  // Adjust padding as necessary
                                    .background(viewModel.selectedDevice == device ? Color.blue: Color.gray.opacity(0.2))
                                    .cornerRadius(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 1)  // Adding a border
                                    )
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
                        Text("Ntrip IP: \(viewModel.ntripConfigData.ip)")
                        Text("Ntrip Port: \(viewModel.ntripConfigData.port)")
                        Text("Ntrip Account: \(viewModel.ntripConfigData.account)")
                        Text("Ntrip Password: \(viewModel.ntripConfigData.password)")
                        Text("Mount Point: \(viewModel.ntripConfigData.currentMountPoint)")
                        Button("Verify Ntrip"){
                            viewModel.connectDiff()
                            viewModel.getMountPoint()}
                        Button("Login Ntrip"){ viewModel.connectDiff()}
                    }
                    .padding()
                }
            }
            .padding()
            .onAppear {
                viewModel.startListening()
            }
            .navigationTitle("RTK Device Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: cancelButton, trailing: connectButton)
            .onAppear {
                viewModel.startListening()
            }
        }
        
    }
    
    var cancelButton: some View {
        Button(action: {
            print("Cancel button tapped!")
            
            // Implement any other actions you want for this button.
        }) {
            Text("Cancel")
        }
    }
    
    var connectButton: some View {
        Button(action: {
            print("Connect button tapped!")
            // Implement any other actions you want for this button.
        }) {
            Text("Connect")
        }
    }
}

struct RtkSettingView_Previews: PreviewProvider {
    static var previews: some View {
        RtkSettingView()
    }
}

