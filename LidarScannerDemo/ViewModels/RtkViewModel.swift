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
    @Published var lastSelectedDevice: String? = nil
    @Published var selectedDevice: String?
    
    
    @Published var rtkService: RtkService
    private var cancellables: Set<AnyCancellable> = []
    private var cancellables_ntrip: Set<AnyCancellable> = []
    init(rtkService: RtkService = RtkService()) {
        self.rtkService = rtkService
        print("rtkService.ntripConfigData.ip = ",self.rtkService.ntripConfigModel.ip)
        setupBindings()
        print("rtkService.ntripConfigData.ip = ",self.rtkService.ntripConfigModel.ip)
    }

    private func setupBindings() {
        rtkService.$rtkData
            .assign(to: \.rtkData, on: self)
            .store(in: &cancellables)
        rtkService.$ntripConfigModel
            .assign(to: \.ntripConfigData, on: self)
            .store(in: &cancellables_ntrip)
    }
    
    func connectDiff(){
        rtkService.toConnectDiff()
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
}
