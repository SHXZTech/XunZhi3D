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
    @Published var diffModel = HCDiffModel()
    @Published var ntripConfigModel = NtripConfigModel()
    @Published var isConnected: Bool = false
    @Published var connectable: Bool = false
    @Published var isLoninSuccessful: Bool = false;
    
    private var currentDeviceIndex: Int = -1
    private var deviceModel: HCDeviceInfoBaseModel?
    private var nmeaSourceText: String?
    private var socketUtil: HCSocketUtil?
    private var timer: Timer?
    private var util: HCUtil?
    
    override init() {
        super.init()
        
        self.socketUtil = HCSocketUtil()
        self.socketUtil?.delegate = self
        //self.util = HCUtil()
        //self.util?.delegate = self
        self.util = HCUtil(delegate: self)
        Task {
            do {
                let loadedConfig = try NtripConfigModel.loadFromLocal()
                self.ntripConfigModel = loadedConfig
            } catch {
                print("Failed to load NtripConfig: \(error)")
                ntripConfigModel.ip = "117.135.142.201"
                ntripConfigModel.port = 8002
                ntripConfigModel.account = "cdea113"
                ntripConfigModel.password = "ktkryu39"
                ntripConfigModel.mountPointList = ["RTCM33_GRCE"]
                ntripConfigModel.currentMountPoint = "RTCM33_GRCE"
                ntripConfigModel.isCertified = false
            }
        }
        
        assertNtripToHCDiff()
    }
    
    func startListening() {
        endListening()
        //util = HCUtil(delegate: self)
        toSearch()
    }
    
    func endListening() {
        toDisconnect(isAuto: true)
        currentDeviceIndex = -1
        //util = nil
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
        guard currentDeviceIndex >= 0, currentDeviceIndex < rtkData.list.count else { return }
        nmeaSourceText = deviceModel?.nmeaSourceText
        rtkData.deviceName = rtkData.list[currentDeviceIndex]
        rtkData.electricity = "\(deviceModel?.electricity ?? "")%"
        rtkData.diffDelay = "\(deviceModel?.diffDelayTime ?? "")"
        rtkData.longitude = "\(deviceModel?.longitude ?? "")"
        rtkData.latitude = "\(deviceModel?.latitude ?? "")"
        rtkData.height = (deviceModel?.height)!
        rtkData.verticalAccuracy = "\(deviceModel?.dz ?? "")"
        rtkData.horizontalAccuracy = "\(deviceModel?.dxy ?? "")"
        rtkData.satelliteCount = "\(deviceModel?.gpsCount ?? "")"
        
        switch deviceModel?.gpsLevelValue ?? 0 {
        case 4:
            rtkData.diffStatus = "固定解"
            rtkData.signalStrength = 3
        case 2:
            rtkData.diffStatus = "码差分"
            rtkData.signalStrength = 2
        case 5:
            rtkData.diffStatus = "浮点解"
            rtkData.signalStrength = 1
        default:
            rtkData.diffStatus = "单点解"
            rtkData.signalStrength = 0
        }
    }
    
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
        if let devices = deviceNameList, devices.count > 0 {
            self.rtkData.list = devices
        }else{
            self.rtkData.list.removeAll()
        }
        
    }
    
    func hcDeviceConnected(_ index: Int) {
        currentDeviceIndex = index
        isConnected = true
    }
    
    func hcReceive(_ deviceInfoBaseModel: HCDeviceInfoBaseModel!) {
        print("hcReceive toggle")
        if currentDeviceIndex < 0 || currentDeviceIndex >= rtkData.list.count {
            return
        }
        print(" deviceModel = HCDeviceInfoBaseModel(model: deviceInfoBaseModel toggle")
        deviceModel = HCDeviceInfoBaseModel(model: deviceInfoBaseModel)
        mapData()
    }
    
    func hcDeviceDisconnected() {
        toDisconnect(isAuto: true)
        isConnected = false
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
    
    func toConnectDiff() {
        assertNtripToHCDiff()
        self.socketUtil?.replaceDiffModel(diffModel)
        self.socketUtil?.toLogin()
    }
    
    func getMountPoint() {
        self.socketUtil?.getMountPoints()
    }
    
    @objc func getDiffData() {
        print("toggle getDiffData")
        if let nmeaSourceText = nmeaSourceText, nmeaSourceText.count > 0 {
            print("nmeaSourceText: ", nmeaSourceText)
            self.socketUtil?.sendData("\(nmeaSourceText)\r\n\r\n")
        }
    }
    
    func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func loginSuccess(_ tcpUtil: HCSocketUtil) {
        self.ntripConfigModel.isCertified = true;
        self.isLoninSuccessful = true
        if timer == nil {//差分登录成功后需要把获取到的差分数据发送到硬件设备
            timer = Timer(timeInterval: 0.5, target: self, selector: #selector(getDiffData), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .common)
        }
        timer?.fireDate = .distantPast
    }
    
    func loginFailure(_ tcpUtil: HCSocketUtil, error: Error?) {
        removeTimer()
        self.socketUtil?.disconnect()
    }
    
    func didGetMountPointsSuccess(_ socketUtil: HCSocketUtil) {
        ntripConfigModel.mountPointList = socketUtil.diffModel.mountPointList
        print("did getmountPointsSuccess:", ntripConfigModel.mountPointList)
        if ntripConfigModel.mountPointList.count > 0 {
            ntripConfigModel.currentMountPoint = ntripConfigModel.mountPointList.first!
            print("currentMountPoint = ", ntripConfigModel.currentMountPoint)
        }
        self.socketUtil?.disconnect()
    }
    
    func didReadOriginDiffDataSuccess(_ data: Data, socketUtil: HCSocketUtil) {
        print(" didReadOriginDiffDataSuccess")
        print("data:", data)
        print("is uitl == nil: ", self.util == nil)
        self.util?.toSend(data)
    }
    
    func assertNtripToHCDiff(){
        diffModel.ip = ntripConfigModel.ip
        diffModel.port = ntripConfigModel.port
        diffModel.account = ntripConfigModel.account
        diffModel.password = ntripConfigModel.password
        diffModel.mountPointList = ntripConfigModel.mountPointList
        diffModel.currentMountPoint = ntripConfigModel.currentMountPoint
    }
    
}

extension RtkService: HCSocketUtilDelegate {
    // Handle delegate methods here similar to your UIViewController
    // Update any necessary @Published properties to reflect changes
}

