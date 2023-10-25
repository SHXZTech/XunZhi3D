//
//  NtripConfigService.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/25.
//

import Foundation
import LiteRTK

class NtripConfigService:NSObject, ObservableObject {
    @Published var diffModel = HCDiffModel()
    @Published var ntripConfigModel = NtripConfigModel()
    private var socketUtil: HCSocketUtil?
    private var timer: Timer?
    @Published var nmeaSourceText: String?
    var util: HCUtil?
    
    override init() {
        super.init()
        self.socketUtil = HCSocketUtil()
        self.socketUtil?.delegate = self
        ntripConfigModel.ip = "203.107.45.154"
        ntripConfigModel.port = 8002
        ntripConfigModel.account = "qxxsrz003"
        ntripConfigModel.password = "4c52c89"
        ntripConfigModel.mountPointList = ["AUTO"]
        ntripConfigModel.currentMountPoint = "AUTO"
        //*****************************
        //ntripConfigModel.loadFromLocal()
        assertNtripToHCDiff()
        
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
//        diffModel.ip = ntripConfigModel.ip
//        diffModel.port = ntripConfigModel.port
//        diffModel.account = ntripConfigModel.account
//        diffModel.password = ntripConfigModel.password
//        diffModel.mountPointList = ntripConfigModel.mountPointList
//        diffModel.currentMountPoint = ntripConfigModel.currentMountPoint
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

extension NtripConfigService: HCSocketUtilDelegate {
    // Handle delegate methods here similar to your UIViewController
    // Update any necessary @Published properties to reflect changes
}
