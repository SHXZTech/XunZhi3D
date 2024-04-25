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
    private var cancellables: Set<AnyCancellable> = []
    private var cancellables_ntrip: Set<AnyCancellable> = []
    init() {
        self.rtkService = RtkService()
        setupBindings()
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
