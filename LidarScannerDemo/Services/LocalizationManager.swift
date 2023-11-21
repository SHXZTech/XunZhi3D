//
//  LocalizationManager.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/13.
//

import Foundation
class LocalizationManager {
    static let shared = LocalizationManager()

    func setLanguage(_ languageCode: String) {
        UserDefaults.standard.set(languageCode, forKey: "selectedLanguage")
        Bundle.setLanguage(languageCode)
    }

    func getCurrentLanguage() -> String {
        UserDefaults.standard.string(forKey: "selectedLanguage") ?? Locale.current.language.languageCode?.identifier ?? "en"
    }
}
