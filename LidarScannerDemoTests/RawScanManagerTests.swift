//
//  awScanManagerTests.swift
//  LidarScannerDemoTests
//
//  Created by Tao Hu on 2023/4/21.
//

import XCTest
import Foundation
@testable import LidarScannerDemo

class RawScanManagerTests: XCTestCase {

    func testisExistCheck() {
        // Create a new UUID and a RawScanManager instance
        let uuid = UUID()
        var scanManager = RawScanManager(uuid: uuid)

        // Create a file with the UUID in the documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderURL = documentsDirectory.appendingPathComponent(uuid.uuidString)
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false)

        // Call isExistCheck() and check the result
        let exists = scanManager.isExistCheck()
        XCTAssertTrue(exists)
        // Delete the file from the documents directory
        try? FileManager.default.removeItem(at: folderURL)
    }
    
    func testisExistCheckNotExist() {
        // Create a new UUID and a RawScanManager instance
        let uuid = UUID()
        var scanManager = RawScanManager(uuid: uuid)

        // Call isExistCheck() and check the result
        let exists = scanManager.isExistCheck()
        XCTAssertFalse(exists)
    }
    
    func testIsRawMeshExistCheck() {
        // Create a new UUID and a RawScanManager instance
        let uuid = UUID()
        var scanManager = RawScanManager(uuid: uuid)

        // Create a file with the UUID in the documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderURL = documentsDirectory.appendingPathComponent(uuid.uuidString)
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false)
        
        // Create a new file called "RawMesh.usd" in the folder
        let rawMeshURL = folderURL.appendingPathComponent("rawMesh.usd")
        let data = "test".data(using: .utf8)
        FileManager.default.createFile(atPath: rawMeshURL.path, contents: data, attributes: nil)
        
        // Call isRawMeshExistCheck() and check the result
        let exists = scanManager.isRawMeshExistCheck()
        XCTAssertTrue(exists)

        // Delete the file and folder from the documents directory
        try? FileManager.default.removeItem(at: rawMeshURL)
        try? FileManager.default.removeItem(at: folderURL)
    }


}



