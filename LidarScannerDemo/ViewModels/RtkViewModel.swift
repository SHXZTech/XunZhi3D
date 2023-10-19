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
    
    init() {
        self.rtkManager = RTKManager()
        setupBindings()
    }
    
    // Setup bindings from manager to the view model's properties
    private func setupBindings() {
        guard let manager = rtkManager else { return }
        
        // Bind manager's properties to view model's properties
        _ = manager.$deviceName.assign(to: &$deviceName)
        _ = manager.$electricity.assign(to: &$electricity)
        _ = manager.$diffStatus.assign(to: &$diffStatus)
        _ = manager.$diffDelay.assign(to: &$diffDelay)
        _ = manager.$longitude.assign(to: &$longitude)
        _ = manager.$latitude.assign(to: &$latitude)
    }
    
    // Add functions that interact with the manager
    
    func startListening() {
        rtkManager?.startListening()
    }
    
    func endListening() {
        rtkManager?.endListening()
    }
    
    func toSearch() {
        rtkManager?.toSearch()
    }
    
    func toDisconnect() {
        rtkManager?.toDisconnect()
    }
}
