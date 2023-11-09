//
//  StringExtension.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/9.
//

import Foundation

extension String {
    func truncated(to length: Int, trailing: String = "...") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
}
