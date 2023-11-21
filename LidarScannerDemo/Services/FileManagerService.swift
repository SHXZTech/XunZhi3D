//
//  FileManagerService.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/15.
//

import Foundation
import os

func calculateFolderSize(folderURL:URL) -> Int64? {
    let fileManager = FileManager.default
    var totalSize: Int64 = 0
    do {
        let resourceKeys : [URLResourceKey] = [.fileSizeKey]
        let enumerator = try fileManager.enumerator(at: folderURL, includingPropertiesForKeys: resourceKeys, options: [], errorHandler: { (url, error) -> Bool in
            print("Error while enumerating files \(url.path): \(error.localizedDescription)")
            return true
        })
        for case let fileURL as URL in enumerator! {
            let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
            if let fileSize = resourceValues.fileSize {
                totalSize += Int64(fileSize)
            }
        }
    } catch {
        print(error)
        return nil
    }
    return totalSize
}

func getFolderCreateDate(folderURL: URL) -> Date? {
    let fileManager = FileManager.default
    do {
        let attributes = try fileManager.attributesOfItem(atPath: folderURL.path)
        return attributes[.creationDate] as? Date
    } catch {
        print("Error retrieving folder creation date: \(error.localizedDescription)")
        return nil
    }
}


func deleteFolder(folderURL: URL) {
    let fileManager = FileManager.default
    do {
        if fileManager.fileExists(atPath: folderURL.path) {
            try fileManager.removeItem(at: folderURL)
        } else {
        }
    } catch {
    }
}
