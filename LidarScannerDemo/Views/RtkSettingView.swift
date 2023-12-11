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
    
    init(viewModel: RTKViewModel,isPresented: Binding<Bool>) {
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
            .navigationTitle(NSLocalizedString("RTK Device Setting", comment: "rtk device setting"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: cancelButton, trailing: connectButton)
            .onAppear {
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
    
    func rtkDataSection() -> some View {
        GroupBox(label: Text(NSLocalizedString("RTK Data", comment: "Header for the section displaying RTK data"))) {
            VStack(alignment: .leading, spacing: 10) {
                Text(NSLocalizedString("Device Name", comment: "Label for displaying the device name") + " \(viewModel.rtkData.deviceName)")
                Text(NSLocalizedString("Electricity", comment: "Label for displaying the electricity level of the device") + " \(viewModel.rtkData.electricity)")
                Text(NSLocalizedString("Diff status", comment: "Label for displaying the differential status of the RTK") + " \(viewModel.rtkData.diffStatus)")
                Text(NSLocalizedString("Longitude", comment: "Label for displaying longitude data") + " \(viewModel.rtkData.longitude)")
                Text(NSLocalizedString("Latitude", comment: "Label for displaying latitude data") + " \(viewModel.rtkData.latitude)")
                Text(NSLocalizedString("Height", comment: "Label for displaying height data") + " \(viewModel.rtkData.height)")
                Text(NSLocalizedString("Horizontal accuracy", comment: "Label for displaying the horizontal accuracy of the RTK data") + " \(viewModel.rtkData.horizontalAccuracy)")
                Text(NSLocalizedString("Vertical accuracy", comment: "Label for displaying the vertical accuracy of the RTK data") + " \(viewModel.rtkData.verticalAccuracy)")
                Text(NSLocalizedString("Satellite count", comment: "Label for displaying the number of satellites connected") + " \(viewModel.rtkData.satelliteCount)")
                Text(NSLocalizedString("Create time", comment: "Label for displaying the creation time of the data") + " \(formattedDate(with: viewModel.rtkData.createTime))")
            }
            .frame(alignment: .leading)
            .padding()
        }
    }
    
    
    func formattedDate(with date: Date) -> String {
        let formatter = DateFormatter()
        // Include milliseconds in the format - "yyyy-MM-dd HH:mm:ss.SSS"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: date)
    }
    
    func rtkNtripConfigSection() -> some View {
        GroupBox(label:
                    HStack {
            Text(NSLocalizedString("Ntrip Data", comment: ""))
            Spacer()
            Text(viewModel.ntripConfigData.isCertified ? NSLocalizedString("Certified", comment: "") : NSLocalizedString("Certification Failed", comment: ""))
                .foregroundColor(viewModel.ntripConfigData.isCertified ? .green : .red)
                .fontWeight(.bold)
        }
        ) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(NSLocalizedString("IP", comment: ""))
                        .frame(width: 100, alignment: .leading)
                    TextField(NSLocalizedString("Ntrip IP", comment: ""), text: $viewModel.ntripConfigData.ip)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Text(NSLocalizedString("Port", comment: ""))
                        .frame(width: 100, alignment: .leading)
                    TextField(NSLocalizedString("Ntrip Port", comment: ""), text: $viewModel.portString)
                        .keyboardType(.numberPad)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Text(NSLocalizedString("Account", comment: ""))
                        .frame(width: 100, alignment: .leading)
                    TextField(NSLocalizedString("Ntrip Account", comment: ""), text: $viewModel.ntripConfigData.account)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Text(NSLocalizedString("Password", comment: ""))
                        .frame(width: 100, alignment: .leading)
                    SecureField(NSLocalizedString("Ntrip Password", comment: ""), text: $viewModel.ntripConfigData.password)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Text(NSLocalizedString("Mount Point", comment: ""))
                        .frame(width: 100, alignment: .leading)
                    TextField(NSLocalizedString("Mount Point", comment: ""), text: $viewModel.ntripConfigData.currentMountPoint)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(NSLocalizedString("Validate Ntrip Service", comment: "")) {
                    viewModel.toVerifyNtrip { isLoginSuccessful in
                        if isLoginSuccessful {
                            do {
                                try viewModel.ntripConfigData.saveToLocal()
                            } catch {
                            }
                        }
                    }
                }
            }
            .frame(alignment: .leading)
            .padding()
        }
    }
    
    
    
    
    
    func rtkBluetoothDeviceSection() -> some View{
        GroupBox(label: Text(NSLocalizedString("RTK BLUETOOTH DEVICE", comment: ""))) {
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
            Text(NSLocalizedString("None", comment: ""))
            Spacer()
            Text(NSLocalizedString("Searching", comment: "")+" ...") // Small "Searching..." text
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
                            viewModel.toDisconnect()
                            viewModel.selectedDevice = nil
                        } else {
                            if let index = viewModel.rtkData.list.firstIndex(of: device) {
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
            self.isPresented = false
        }) {
            Text(NSLocalizedString("Cancel", comment: ""))
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
            Text(NSLocalizedString("Connect", comment: ""))
        }
        .alert(isPresented: $showingWarningAlert) {
            Alert(title: Text(NSLocalizedString("Warning", comment: "")),
                  message: Text(warningMessage(for: currentWarning)),
                  dismissButton: .default(Text(NSLocalizedString("OK", comment: ""))) {
                //RtkService.
                startTimer()  // Restart the timer once the alert is dismissed
            })
        }
    }
    
    func startTimer() {
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
            return NSLocalizedString("Please select a connected device.", comment: "")
        case .ntripConfigFail:
            return NSLocalizedString("Ntrip config failed.", comment: "")
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







