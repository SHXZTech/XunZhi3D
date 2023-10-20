//
//  NtripConfigViewModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/20.
//

import Foundation
import LiteRTK

class NtripConfigViewModel:NSObject, ObservableObject {
    @Published var diffModel = HCDiffModel()
    @Published var ntripConfigModel = NtripConfigModel()
    private var socketUtil: HCSocketUtil?
    private var timer: Timer?
    var nmeaSourceText: String?
    var util: HCUtil?

    override init() {
        super.init()
        self.socketUtil = HCSocketUtil()
        self.socketUtil?.delegate = self
        //TEST, DEBUG: The following setting just for 1-time test, remove after test
        ntripConfigModel.ip = ""
    }

    func toConnectDiff() {
        self.socketUtil?.replaceDiffModel(diffModel)
        self.socketUtil?.toLogin()
    }

    func getMountPoint() {
        self.socketUtil?.getMountPoints()
    }

    func getDiffData() {
        if let nmeaSourceText = nmeaSourceText, nmeaSourceText.count > 0 {
            self.socketUtil?.sendData("\(nmeaSourceText)\r\n\r\n")
        }
    }

    func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension NtripConfigViewModel: HCSocketUtilDelegate {
    // Handle delegate methods here similar to your UIViewController
    // Update any necessary @Published properties to reflect changes
}
