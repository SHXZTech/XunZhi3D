//
//  BundelExtension.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/13.
//

import Foundation
extension Bundle {
    private static var bundle: Bundle!

    static func setLanguage(_ language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return }

        self.bundle = bundle
    }

    static func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
