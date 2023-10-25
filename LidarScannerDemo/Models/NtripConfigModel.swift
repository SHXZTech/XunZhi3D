//
//  NtripConfigModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/20.
//

import Foundation


struct NtripConfigModel: Codable {
    var ip: String = ""
    var port: Int = 0
    var account: String = ""
    var password: String = ""
    var mountPointList: [String] = []
    var currentMountPoint: String = ""
    var isCertified: Bool = false
    
    
}


extension NtripConfigModel {
    static let configFilename = "ntrip_config.json"
    
    // Returns the URL for the config file in the app's document directory.
    static func configFileURL() -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(configFilename)
    }
    
    // Save the configuration to a local file.
    func saveToLocal() -> Bool {
        guard let url = NtripConfigModel.configFileURL() else {
            return false
        }
        
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: url)
            return true
        } catch {
            print("Error saving NtripConfig: \(error)")
            return false
        }
    }
    
    // Load the configuration from a local file.
    static func loadFromLocal() -> NtripConfigModel? {
        guard let url = NtripConfigModel.configFileURL() else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(NtripConfigModel.self, from: data)
            return config
        } catch {
            print("Error loading NtripConfig: \(error)")
            return nil
        }
    }
}
