//
//  RtkViewModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/19.
//
// RTKViewModel.swift

import Foundation
import Combine
import LiteRTK

class RTKViewModel: ObservableObject {
    @Published var rtkData: RtkModel = RtkModel()
    @Published var ntripConfigData = NtripConfigModel()
    @Published var selectedDevice: String?
    @Published var rtkService: RtkService
    private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    private var cancellables: Set<AnyCancellable> = []
    private var cancellables_ntrip: Set<AnyCancellable> = []
    
    init() {
        self.rtkService = RtkService()
        setupBindings()
        startAutoSearchTimer()
    }
    
    private func setupBindings() {
        rtkService.$rtkData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newRtkData in
                self?.rtkData = newRtkData
            }
            .store(in: &cancellables)
        
        rtkService.$ntripConfigModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newNtripConfigData in
                self?.ntripConfigData = newNtripConfigData
            }
            .store(in: &cancellables_ntrip)
        
        rtkService.$isConnected
            .receive(on: RunLoop.main)
            .sink { [weak self] isConnected in
                if isConnected, let self = self {
                    // Optionally stop the timer if the device is connected
                    self.stopTimer()
                }
            }
            .store(in: &cancellables)
    }
    
    // In RTKViewModel
    func viewDidAppear() {
        print("view disappear")
        startAutoSearchTimer()
        if !isConnected() {
            startListening()
        }
    }

    func viewDidDisappear() {
        print("view disappear")
        stopTimer()
        toDisconnect()
        endListening()  // If you want to stop listening when the view is not visible
    }

    
    func startAutoSearchTimer() {
        // Start the timer and immediately connect it to a sink that manages its events.
        let subscription = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                self?.autoSearchAndConnect()
            }
        // Store the subscription in the cancellables set to manage its lifecycle correctly.
        subscription.store(in: &cancellables)
    }

    func autoSearchAndConnect() {
        print("is connected?:", rtkService.isConnected)
        print("Available devices:", rtkData.list)
        print("Selected device:", selectedDevice ?? "None")
        
        if !rtkService.isConnected {
            if let firstDevice = rtkData.list.first {
                print("Attempting to connect to first available device:", firstDevice)
                if let index = rtkData.list.firstIndex(of: firstDevice) {
                    selectedDevice = firstDevice  // Optionally set the first device as selected
                    toConnect(index: index)
                    print("debug 1 to connect index:", index)
                }
            } else {
                rtkService.startListening()
                print("autoSearchAndConnect(): start listening")
            }
        } else {
            stopTimer()
            print("stop timer as connected")
        }
    }
    
//    func startTimer() {
//        self.timer.upstream.connect().cancel() // Ensure we cancel any existing timer
//        self.timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
//    }
    
    func stopTimer() {
        print("Stopping RTK ViewModel Timer")
        cancellables.forEach { $0.cancel() }  // This cancels all subscriptions, including the timer.
        cancellables.removeAll()  // Optionally clear the set if you are restarting the timer later.
    }

    
    func connectDiff(){
        rtkService.toConnectDiff()
    }
    
    func startRecord(uuid: UUID){
        rtkService.startRecord(uuid_: uuid)
    }
    
    public func toVerifyNtrip(completion: @escaping (Bool) -> Void) {
        rtkService.isLoninSuccessful = false
        rtkService.ntripConfigModel.isCertified = false
        rtkService.toConnectDiff()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completion(self.rtkService.isLoninSuccessful)
        }
    }
    
    func getRtkData()-> RtkModel{
        return rtkData
    }
    
    func getMountPoint(){
        rtkService.getMountPoint()
    }
    
    func startListening() {
        rtkService.startListening()
    }
    
    func endListening() {
        rtkService.endListening()
    }
    
    func toSearch() {
        rtkService.toSearch()
    }
    
    func toConnect(index: Int) {
        rtkService.toConnect(itemIndex: index)
    }
    
    func toDisconnect() {
        rtkService.toDisconnect()
    }
    
    func isConnected()-> Bool{
        return rtkService.isConnected
    }
    
    var portString: String {
        get {
            return String(ntripConfigData.port)
        }
        set {
            if let newPort = Int(newValue) {
                ntripConfigData.port = newPort
            }
        }
    }
}
