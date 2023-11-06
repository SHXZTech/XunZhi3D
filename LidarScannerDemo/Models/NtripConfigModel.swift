//
//  NtripConfigModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/20.
//

import Foundation

import Foundation

struct NtripConfigModel: Codable {
    var ip: String = ""
    var port: Int = 0
    var account: String = ""
    var password: String = ""
    var mountPointList: [String] = []
    var currentMountPoint: String = ""
    var isCertified: Bool = false
    
    enum FileError: Error {
        case directoryNotFound
        case fileNotSaved
        case fileNotLoaded
    }
    
    // Save the configuration to a local file.
    func saveToLocal() throws {
        guard let url = NtripConfigModel.configFileURL() else {
            throw FileError.directoryNotFound
        }
        
        let data = try JSONEncoder().encode(self)
        do {
            try data.write(to: url)
        } catch {
            print("Error saving NtripConfig: \(error)")
            throw FileError.fileNotSaved
        }
    }
    
    // Load the configuration from a local file.
    static func loadFromLocal() throws -> NtripConfigModel {
        guard let url = configFileURL() else {
            throw FileError.directoryNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(NtripConfigModel.self, from: data)
            return config
        } catch {
            print("Error loading NtripConfig: \(error)")
            throw FileError.fileNotLoaded
        }
    }
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
}
