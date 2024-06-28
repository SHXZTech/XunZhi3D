//
//  StringExtension.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/9.
//

import Foundation
import CryptoKit

extension String {
    func truncated(to length: Int, trailing: String = "...") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
}

extension String {
    func sha256() -> String {
        let inputData = Data(self.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
