//
//  RtkService.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/24.
//

import Foundation
import SwiftUI
import Combine
import LiteRTK

class RtkService: NSObject, ObservableObject, HCUtilDelegate {
    @Published var rtkData: RtkModel = RtkModel()
    @Published var isConnected: Bool = false
    @Published var connectable: Bool = false

    
    private var util: HCUtil?
    private var currentDeviceIndex: Int = -1
    private var deviceModel: HCDeviceInfoBaseModel?
    
    override init() {
        super.init()
        setUpService()
    }
    
    private func setUpService() {
        util = HCUtil(delegate: self)
    }
    
    func startListening() {
        endListening()
        util = HCUtil(delegate: self)
        toSearch()
    }
    
    func endListening() {
        toDisconnect(isAuto: true)
        currentDeviceIndex = -1
        util = nil
        rtkData.list.removeAll()
    }
    
    func toSearch() {
        print("RtkService is searching for devices")
        rtkData.list.removeAll()
        util?.toSearchDevice(with: .BleRTK)
    }
    
    func toDisconnect(isAuto: Bool = false) {
        currentDeviceIndex = -1
        if !isAuto {
            util?.toDisconnect()
        }
    }
    
    func toConnect(itemIndex: Int) {
        util?.toConnectDevice(itemIndex)
    }
    
    func mapData() {
        print("mapData")
        print("currentDeviceIndex=", currentDeviceIndex)
        print("deviceList")
        guard currentDeviceIndex >= 0, currentDeviceIndex < rtkData.list.count else { return }
        
        rtkData.deviceName = rtkData.list[currentDeviceIndex]
        rtkData.electricity = "\(deviceModel?.electricity ?? "")%"
        rtkData.diffDelay = "\(deviceModel?.diffDelayTime ?? "")"
        rtkData.longitude = "\(deviceModel?.longitude ?? "")"
        rtkData.latitude = "\(deviceModel?.latitude ?? "")"
        
        switch deviceModel?.gpsLevelValue ?? 0 {
        case 4:
            rtkData.diffStatus = "固定解"
        case 2:
            rtkData.diffStatus = "码差分"
        case 5:
            rtkData.diffStatus = "浮点解"
        default:
            rtkData.diffStatus = "单点解"
        }
    }
    
    // HCUtilDelegate methods
    // ... (Implement the delegate methods as before)
    func hcDeviceDidFailWithError(_ error: HCStatusError) {
        // Handle error as needed
        switch error {
        case .BleUnauthorized:
            print("蓝牙未授权")
            break
        case .UnsupportedDeviceType:
            print("不支持该设备连接")
            break
        case .BlePoweredOff:
            self.rtkData.list.removeAll()
            print("手机蓝牙未开启，请先开启后再连接设备")
            break
        case .Unknown:
            break
        default:
            break
        }
    }
    
    func hcSearchResult(_ deviceNameList: [String]!, isDone: Bool) {
        print("Device Name List: \(deviceNameList ?? [])")
        if let devices = deviceNameList, devices.count > 0 {
            self.rtkData.list = devices
            // You might also use some method to show a list in SwiftUI
            print("search successfully")
            print(devices.count)
        }else{
            print("search fail")
            self.rtkData.list.removeAll()
        }
        
    }
    
    func hcDeviceConnected(_ index: Int) {
        currentDeviceIndex = index
        isConnected = true
        print("RTK connected")
    }
    
    func hcReceive(_ deviceInfoBaseModel: HCDeviceInfoBaseModel!) {
        print("hcReceived")
        print("receive data")
        if currentDeviceIndex < 0 || currentDeviceIndex >= rtkData.list.count {
            return
        }
        deviceModel = HCDeviceInfoBaseModel(model: deviceInfoBaseModel)
        mapData()
    }
    
    func hcDeviceDisconnected() {
        toDisconnect(isAuto: true)
        isConnected = false
        print("RTK disconnected")
    }
    
    func hcReceiveRTCMData(_ data: Data!) {
        // Handle RTCM data
    }
    
    func hcReceiveUBXData(_ data: Data!) {
        // Handle UBX data
    }
    
    func isConnectable() -> Bool {
        return !rtkData.list.isEmpty
    }
}

