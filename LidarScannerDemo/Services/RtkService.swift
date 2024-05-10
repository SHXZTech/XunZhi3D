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
    @Published var isFixed: Bool = false;
    
    private var uuid: UUID?
    
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
        self.util = HCUtil(delegate: self)
        Task {
            //TODO: make the ntrip is configed from the server side, not the local file
            do {
                let loadedConfig = try NtripConfigModel.loadFromLocal()
                self.ntripConfigModel = loadedConfig
            } catch {
                ntripConfigModel.ip = "203.107.45.154"
                ntripConfigModel.port = 8002
                ntripConfigModel.account = "qxxsrz005"
                ntripConfigModel.password = "5ed64b4"
                ntripConfigModel.mountPointList = ["AUTO"]
                ntripConfigModel.currentMountPoint = "AUTO"
                ntripConfigModel.isCertified = false
            }
        }
        assertNtripToHCDiff()
        startListening() //AutoConnect
    }
    
    func startListening() {
        endListening()
        toSearch()
        print("start listening")
    }
    
    func endListening() {
        toDisconnect(isAuto: true)
        currentDeviceIndex = -1
        rtkData.list.removeAll()
    }
    
    func toSearch() {
        rtkData.list.removeAll()
        util?.toSearchDevice(with: .BleRTK)
        print("to search")
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
    
    func startRecord(uuid_: UUID)
    {
        self.uuid = uuid_;
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
        rtkData.createTime = deviceModel?.createTime ?? Date()
        rtkData.timeStamp = Date()
        print("map data:", rtkData)
        print("isConnected:", isConnected)
        switch deviceModel?.gpsLevelValue ?? 0 {
        case 4:
            rtkData.diffStatus = "固定解"
            rtkData.signalStrength = 3
            self.isFixed = true
        case 2:
            rtkData.diffStatus = "码差分"
            rtkData.signalStrength = 2
            self.isFixed = false
        case 5:
            rtkData.diffStatus = "浮点解"
            rtkData.signalStrength = 1
            self.isFixed = false
        default:
            rtkData.diffStatus = "单点解"
            rtkData.signalStrength = 0
            self.isFixed = false
        }
        if let uuid = uuid {
            let dataFolder =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(uuid.uuidString)
            let rtkFolder = dataFolder.appendingPathComponent("rtk")
                saveRtkDataToInfoJson(rtkData: rtkData, DataFolder: rtkFolder)
            }
        print("map data: rtiData.diffStatus:", rtkData.diffStatus)
    }

    func hcDeviceDidFailWithError(_ error: HCStatusError) {
        print("hcDeviceDidFailWithError",hcDeviceDidFailWithError)
        switch error {
        case .BleUnauthorized:
            break
        case .UnsupportedDeviceType:
            break
        case .BlePoweredOff:
            self.rtkData.list.removeAll()
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
        print("debug!!: isconnected = ", isConnected)
    }
    
    func hcReceive(_ deviceInfoBaseModel: HCDeviceInfoBaseModel!) {
        print("hcReceive")
        if currentDeviceIndex < 0 || currentDeviceIndex >= rtkData.list.count {
            print("debug hcReceive, currentDeviceIndex = ", currentDeviceIndex)
            print("debug hcReceive, rtkData.list.count = ", rtkData.list.count)
            return
        }
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
        self.socketUtil?.enableMorePackages = !(self.util?.isNewBle() ?? false)
        self.socketUtil?.replaceDiffModel(diffModel)
        self.socketUtil?.toLogin()
    }
    
    func getMountPoint() {
        self.socketUtil?.getMountPoints()
    }
    
    @objc func getDiffData() {
        if let nmeaSourceText = nmeaSourceText, nmeaSourceText.count > 0 {
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
        if ntripConfigModel.mountPointList.count > 0 {
            ntripConfigModel.currentMountPoint = ntripConfigModel.mountPointList.first!
        }
        self.socketUtil?.disconnect()
    }
    
    func didReadOriginDiffDataSuccess(_ data: Data, socketUtil: HCSocketUtil) {
        if self.util?.isNewBle() == true {
            self.util?.toSend(data)
        }
    }
    
    func didReadDiffDataSuccess(_ datas: [Data], socketUtil: HCSocketUtil) {
        if let util = self.util{
            RTKController.send(datas, to: util)
        }
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

extension RtkService {
    func saveRtkDataToInfoJson(rtkData: RtkModel, DataFolder: URL) {
        
        let timeStampSince1970 = rtkData.timeStamp.timeIntervalSince1970
        let timeStampString = String(format: "%.15f", timeStampSince1970) + ".json" // For an integer representation
        let infoJsonURL = DataFolder.appendingPathComponent(timeStampString)
        do {
            if !FileManager.default.fileExists(atPath: DataFolder.path) {
                try FileManager.default.createDirectory(at: DataFolder, withIntermediateDirectories: true, attributes: nil)
            }
            var existingJson: [String: Any] = [:]
            let rtkJsonData = try JSONEncoder().encode(rtkData)
            let rtkJson = try JSONSerialization.jsonObject(with: rtkJsonData) as? [String: Any] ?? [:]
            var rtkDataArray = existingJson["rtkData"] as? [[String: Any]] ?? []
            rtkDataArray.append(rtkJson)
            existingJson["rtkData"] = rtkDataArray
            // Write the updated JSON back to the file
            let updatedJsonData = try JSONSerialization.data(withJSONObject: existingJson, options: .prettyPrinted)
            try updatedJsonData.write(to: infoJsonURL)
        } catch {
            // Handle any errors
        }
    }

    
}


