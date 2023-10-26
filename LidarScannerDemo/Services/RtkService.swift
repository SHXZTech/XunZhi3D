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
    
    private var currentDeviceIndex: Int = -1
    private var deviceModel: HCDeviceInfoBaseModel?
    private var nmeaSourceText: String?
    private var socketUtil: HCSocketUtil?
    private var timer: Timer?
   
    var util: HCUtil?
    
    override init() {
        super.init()
        setUpService()
        
        self.socketUtil = HCSocketUtil()
        self.socketUtil?.delegate = self
//        ntripConfigModel.ip = "203.107.45.154"
//        ntripConfigModel.port = 8002
//        ntripConfigModel.account = "qxxsrz003"
//        ntripConfigModel.password = "4c52c89"
//        ntripConfigModel.mountPointList = ["AUTO"]
//        ntripConfigModel.currentMountPoint = "AUTO"
        ntripConfigModel.ip = "117.135.142.201"
        ntripConfigModel.port = 8002
        ntripConfigModel.account = "cdea113"
        ntripConfigModel.password = "ktkryu39"
        ntripConfigModel.mountPointList = ["RTCM33_GRCE"]
        ntripConfigModel.currentMountPoint = "RTCM33_GRCE"
        assertNtripToHCDiff()
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
    
    func toConnectDiff() {
        assertNtripToHCDiff()
        print(">>>>>>>>>>>>>> connecting diff")
        print("diffModel.ip = ", diffModel.ip)
        print("diffModel.port = ", diffModel.port)
        print("diffModel.account = ", diffModel.account)
        print("diffModel.password = ", diffModel.password)
        print("diffModel.mountPointList = ", diffModel.mountPointList)
        print("diffModel.currentMountPoint = ", diffModel.currentMountPoint)
        self.socketUtil?.replaceDiffModel(diffModel)
        self.socketUtil?.toLogin()
    }
    
    func getMountPoint() {
        print("toggle getMointPoint")
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
        print("toggle login success!")
        if timer == nil {//差分登录成功后需要把获取到的差分数据发送到硬件设备
            timer = Timer(timeInterval: 0.5, target: self, selector: #selector(getDiffData), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .common)
        }
        timer?.fireDate = .distantPast
    }
    
    func loginFailure(_ tcpUtil: HCSocketUtil, error: Error?) {
        print("Login failure")
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

