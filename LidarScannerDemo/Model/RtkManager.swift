//
//  RtkManager.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/19.
//

import Foundation
import SwiftUI
import Combine
import LiteRTK

class RTKManager: NSObject, ObservableObject, HCUtilDelegate {
    
    // Properties for SwiftUI to observe
    @Published var deviceName: String = ""
    @Published var electricity: String = ""
    @Published var diffStatus: String = ""
    @Published var diffDelay: String = ""
    @Published var longitude: String = ""
    @Published var latitude: String = ""
    @Published var connectable: Bool = false
    
    var list: [String] = []
    var util: HCUtil?
    var currentDeviceIndex: Int = -1
    var deviceModel: HCDeviceInfoBaseModel?
    
    
    override init() {
        super.init()
        util = HCUtil(delegate: self)
    }
    
    // Start Listening - Equivalent to the UIKit version
    func startListening() {
        endListening()
        util = HCUtil(delegate: self)
        toSearch()
    }
    
    // End Listening - Equivalent to the UIKit version
    func endListening() {
        toDisconnect(isAuto: true)
        currentDeviceIndex = -1
        util = nil
        list.removeAll()
    }
    
    // Search - Equivalent to the UIKit version
    func toSearch() {
        print("RtkManager to search")
        list.removeAll()
        util?.toSearchDevice(with: .BleRTK)
    }
    
    // Disconnect - Equivalent to the UIKit version
    func toDisconnect(isAuto: Bool = false) {
        currentDeviceIndex = -1
        if !isAuto {
            util?.toDisconnect()
        }
    }
    
    func toConnect(itemIndex: Int){
        util?.toConnectDevice(itemIndex)
    }
    

    
    // Mapping the data, similar to setData in UIKit
    func mapData() {
        deviceName = list[currentDeviceIndex]
        electricity = "\(deviceModel?.electricity ?? "")%"
        diffDelay = "\(deviceModel?.diffDelayTime ?? "")"
        longitude = "\(deviceModel?.longitude ?? "")"
        latitude = "\(deviceModel?.latitude ?? "")"
        
        switch deviceModel?.gpsLevelValue ?? 0 {
        case 4:
            diffStatus = "固定解"
        case 2:
            diffStatus = "码差分"
        case 5:
            diffStatus = "浮点解"
        default:
            diffStatus = "单点解"
        }
    }
    
    // HCUtilDelegate methods
    func hcDeviceDidFailWithError(_ error: HCStatusError) {
        // Handle error as needed
    }
    
    func hcSearchResult(_ deviceNameList: [String]!, isDone: Bool) {
        if let devices = deviceNameList, devices.count > 0 {
            self.list = devices
            // You might also use some method to show a list in SwiftUI
            print("search successfully")
            print(devices.count)
        }else{
            print("search fail")
            self.list.removeAll()
        }
        
    }
    
    func hcDeviceConnected(_ index: Int) {
        currentDeviceIndex = index
    }
    
    func hcReceive(_ deviceInfoBaseModel: HCDeviceInfoBaseModel!) {
        if currentDeviceIndex < 0 || currentDeviceIndex >= list.count {
            return
        }
        deviceModel = HCDeviceInfoBaseModel(model: deviceInfoBaseModel)
        mapData()
    }
    
    func hcDeviceDisconnected() {
        toDisconnect(isAuto: true)
    }
    
    func hcReceiveRTCMData(_ data: Data!) {
        // Handle RTCM data
    }
    
    func hcReceiveUBXData(_ data: Data!) {
        // Handle UBX data
    }
    
    func isConnectable() -> Bool{
        if list.isEmpty{
            return false;
        }else{
            return true;
        }
    }
}


