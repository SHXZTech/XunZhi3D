import SwiftUI

struct RtkSettingView: View {
    @ObservedObject var viewModel: RTKViewModel
    @Binding var isPresented: Bool
    
    @State private var rtkSearchToggle: Bool = false
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    
    init(viewModel: RTKViewModel = RTKViewModel(),isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self._isPresented = isPresented
    }
    
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                GroupBox(label: Text("RTK BLUETOOTH DEVICE")) {
                    VStack(spacing: 20) {
                        if viewModel.rtkData.list.isEmpty {
                            HStack {
                                Text("None")
                                Spacer()
                                
                                Text("Searching...") // Small "Searching..." text
                                    .font(.footnote)
                                    .foregroundColor(Color.gray)
                                
                                ProgressView() // Loading spinner
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                            }
                            .frame(height: 30)
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        } else {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                ForEach(viewModel.rtkData.list, id: \.self) { device in
                                    Text(device)
                                        .frame(maxWidth: .infinity, minHeight: 30)
                                        .padding(10)  // Adjust padding as necessary
                                        .background(viewModel.selectedDevice == device ? Color.blue : Color.gray.opacity(0.2))
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
                                                }
                                                viewModel.selectedDevice = device
                                            }
                                        }
                                }
                            }
                            .padding()

                        }
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
            .navigationTitle("RTK Device Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: cancelButton, trailing: connectButton)
            .onAppear {
                viewModel.startListening()
                toggleRtkSearch()
            }
            .onDisappear {
                // Invalidate the timer when the view disappears
                self.timer.upstream.connect().cancel()
            }
            .onReceive(timer) { _ in
                toggleRtkSearch()
            }
        }
        
    }
    
    var cancelButton: some View {
        Button(action: {
            print("Cancel button tapped!")
            self.isPresented = false
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
    
    func toggleRtkSearch() {
        rtkSearchToggle.toggle()
        // Call your RTK search function here based on the rtkSearchToggle state
        if rtkSearchToggle {
            // Call start or search RTK function
            print("Searching RTK...")
            viewModel.startListening()
        } else {
            // Call stop RTK function
            print("Stopping RTK search...")
        }
    }
}

struct RtkSettingView_Previews: PreviewProvider {
    static var previews: some View {
        RtkSettingView(isPresented: .constant(true))
    }
}






