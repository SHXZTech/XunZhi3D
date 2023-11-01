import SwiftUI

struct RtkSettingView: View {
    @ObservedObject var viewModel: RTKViewModel
    @Binding var isPresented: Bool
    @State private var showingWarningAlert = false
    @State private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    enum WarningType {
        case noDeviceConnected
        case ntripConfigFail
        case none
    }
    
    @State private var currentWarning: WarningType = .none
    
    init(viewModel: RTKViewModel = RTKViewModel(),isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self._isPresented = isPresented
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                rtkBluetoothDeviceSection()
                rtkDataSection()
                rtkNtripConfigSection()
            }
            .padding()
            .navigationTitle("RTK Device Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: cancelButton, trailing: connectButton)
            .onAppear {
                print("On appear toggle")
                if(!viewModel.rtkService.isConnected){
                    viewModel.startListening()
                    toggleRtkSearch()
                    startTimer()
                }
            }
            .onDisappear {
                self.timer.upstream.connect().cancel()
            }
            .onReceive(timer) { _ in
                toggleRtkSearch()
            }
        }
    }
    
    func rtkDataSection()-> some View{
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
            .frame(alignment: .leading)
            .padding()
        }
    }
    
    func rtkNtripConfigSection() -> some View {
        GroupBox(label:
            HStack {
                Text("Ntrip Data")
                Spacer()
                Text(viewModel.ntripConfigData.isCertified ? "认证成功" : "认证失败")
                    .foregroundColor(viewModel.ntripConfigData.isCertified ? .green : .red)
                    .fontWeight(.bold)
            }
        ) {
            VStack(alignment: .leading, spacing: 10) {
                TextField("Ntrip IP", text: $viewModel.ntripConfigData.ip)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Ntrip Port", text: $viewModel.portString)  // Updated line
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                TextField("Ntrip Account", text: $viewModel.ntripConfigData.account)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Ntrip Password", text: $viewModel.ntripConfigData.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Mount Point", text: $viewModel.ntripConfigData.currentMountPoint)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("验证Ntrip服务") {
                    viewModel.toVerifyNtrip { isLoginSuccessful in
                        if isLoginSuccessful {
                            print("verify success")
                            do {
                                try viewModel.ntripConfigData.saveToLocal()
                                print("save ntrip ConfiData")
                            } catch {
                                print("save to local fail: \(error)")
                            }
                        } else {
                            print("verify fail")
                        }
                    }
                }
            }
            .frame(alignment: .leading)
            .padding()
        }
    }

    
    
    func rtkBluetoothDeviceSection() -> some View{
        //TODO change the rtkBluetoothSearchedDeviceList() to be fixed
        GroupBox(label: Text("RTK BLUETOOTH DEVICE")) {
            VStack(spacing: 20) {
                if viewModel.rtkData.list.isEmpty {
                    rtkBluetoothSearchingDevice()
                } else {
                 rtkBluetoothSearchedDeviceList()
                }
            }
        }
        .frame(height: 200)
        .padding(.horizontal)
    }
    
    func rtkBluetoothSearchingDevice()-> some View{
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
    }
    
    func rtkBluetoothSearchedDeviceList() -> some View{
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
                                if(viewModel.rtkService.ntripConfigModel.isCertified){
                                    viewModel.rtkService.toConnectDiff()
                                }
                            }
                            viewModel.selectedDevice = device
                        }
                    }
            }
        }
        .padding()
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                determineWarning()
                if currentWarning != .none {
                    self.timer.upstream.connect().cancel() // Cancel the timer immediately
                    showingWarningAlert = true
                } else {
                    
                    viewModel.rtkService.toConnectDiff()
                    self.isPresented = false
                }
            }
        }) {
            Text("Connect")
        }
        .alert(isPresented: $showingWarningAlert) {
            Alert(title: Text("Warning"),
                  message: Text(warningMessage(for: currentWarning)),
                  dismissButton: .default(Text("OK")) {
                //RtkService.
                startTimer()  // Restart the timer once the alert is dismissed
            })
        }
    }
    
    func startTimer() {
        print("timer start")
        self.timer.upstream.connect().cancel() // Ensure we cancel any existing timer
        self.timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    }
    
    func stopTimer(){
        self.timer.upstream.connect().cancel() // Cancel the timer immediately
    }
    
    
    func toggleRtkSearch() {
        if ((viewModel.selectedDevice?.isEmpty) == nil)
        {
            viewModel.startListening()
        }
    }
    
    func determineWarning() {
        if viewModel.selectedDevice == nil {
            currentWarning = .noDeviceConnected
        } else if !viewModel.ntripConfigData.isCertified { // Assuming isCertified checks for Ntrip config
            currentWarning = .ntripConfigFail
        } else {
            currentWarning = .none
        }
    }
    
    func warningMessage(for warningType: WarningType) -> String {
        switch warningType {
        case .noDeviceConnected:
            return "Please select a connected device."
        case .ntripConfigFail:
            return "Ntrip config failed."
        case .none:
            return "" // This won't be shown, but it's good to handle all cases
        }
    }
    
    
}

struct RtkSettingView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = RTKViewModel()
        RtkSettingView(viewModel: viewModel, isPresented: .constant(true))
    }
}







