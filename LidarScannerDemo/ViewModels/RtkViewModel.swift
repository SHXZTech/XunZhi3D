//
//  RtkViewModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/19.
//
// RTKViewModel.swift

import Foundation
import Combine

class RTKViewModel: ObservableObject {
    private var rtkManager: RTKManager?
    
    // Define properties for your SwiftUI view to observe
    @Published var deviceName: String = ""
    @Published var electricity: String = ""
    @Published var diffStatus: String = ""
    @Published var diffDelay: String = ""
    @Published var longitude: String = ""
    @Published var latitude: String = ""
    @Published var deviceList: [String] = []
    @Published var lastSelectedDevice: String? = nil
    
    @Published var selectedDevice: String?

    
    init() {
        self.rtkManager = RTKManager()
        setupBindings()
    }
    
    // Setup bindings from manager to the view model's properties
    private func setupBindings() {
        guard let manager = rtkManager else { return }
        
        // Bind manager's properties to view model's properties
        manager.$deviceName.assign(to: &$deviceName)
        manager.$electricity.assign(to: &$electricity)
        manager.$diffStatus.assign(to: &$diffStatus)
        manager.$diffDelay.assign(to: &$diffDelay)
        manager.$longitude.assign(to: &$longitude)
        manager.$latitude.assign(to: &$latitude)
        manager.$list.assign(to: &$deviceList)
    }
    
    // Add functions that interact with the manager
    
    func startListening() {
        rtkManager?.startListening()
        print("start Listening 搜索到的设备：\(deviceList)")
    }
    
    func endListening() {
        rtkManager?.endListening()
    }
    
    func toSearch() {
        print("Debug RtkViewModel_toSearch")
        rtkManager?.toSearch()
        print("Debug RtkViewModel_toSearch Device Name List: \(deviceList )")
    }
    
    func toConnect(index: Int){
        rtkManager?.toConnect(itemIndex: index)
    }
    
    func toDisconnect() {
        rtkManager?.toDisconnect()
    }
    
//    func isConnectable(){
//    }
}
