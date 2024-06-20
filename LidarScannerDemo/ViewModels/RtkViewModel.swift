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
    //private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    private var timer: Timer?
    private var cancellables: Set<AnyCancellable> = []
    //private var timer_cancellables: Set<AnyCancellable> = []
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
                    self.stopTimer()
                }
            }
            .store(in: &cancellables)
    }
    
    // In RTKViewModel
    func viewDidAppear() {
        startAutoSearchTimer()
        if !isConnected() {
            startListening()
        }
    }

    func viewDidDisappear() {
        stopTimer()
        toDisconnect()
        endListening()
    }


    
    func startAutoSearchTimer() {
            stopTimer()
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
                self?.autoSearchAndConnect()
            }
        }

    func autoSearchAndConnect() {
        
        if !rtkService.isConnected {
            if let firstDevice = rtkData.list.first {
                if let index = rtkData.list.firstIndex(of: firstDevice) {
                    selectedDevice = firstDevice  // Optionally set the first device as selected
                    toConnect(index: index)
                }
            } else {
                rtkService.startListening()
            }
        } else {
            stopTimer()
        }
    }

    
    func stopTimer() {
            timer?.invalidate()
            timer = nil
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
    
    func isFixed()->Bool{
        return rtkService.isFixed
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
