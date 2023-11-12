//
//  LidarMeshModelTest.swift
//  LidarScannerDemoTests
//
//  Created by Tao Hu on 2023/4/25.
//
import XCTest
import simd
@testable import LidarScannerDemo

class LidarMeshModelTests: XCTestCase {

    var model: LidarMeshModel!
    
    override func setUpWithError() throws {
        model = LidarMeshModel(uuid_: UUID())
    }

    func testCalculatePoseDistance() throws {
        let currentFramePose = simd_float4x4(
            simd_float4(1.0, 0.0, 0.0, 0.0),
            simd_float4(0.0, 1.0, 0.0, 0.0),
            simd_float4(0.0, 0.0, 1.0, 0.0),
            simd_float4(1.0, 1.0, 1.0, 1.0)
        )
        let previousFramePose = simd_float4x4(
            simd_float4(1.0, 0.0, 0.0, 0.0),
            simd_float4(0.0, 1.0, 0.0, 0.0),
            simd_float4(0.0, 0.0, 1.0, 0.0),
            simd_float4(0.0, 0.0, 0.0, 1.0)
        )
        
        
        let distance = model.calculatePoseDistance(currentFramePose: currentFramePose, previousFramePose: previousFramePose)
        print("distance \(distance)")
        XCTAssertEqual(distance, 1.73205080757, accuracy: 0.0001, "Distance calculation is incorrect")
    }
    
    func testCalculatePoseAngleDifference() throws {
        let currentFramePose = simd_float4x4(
            simd_float4(1.0, 0.0, 0.0, 0.0),
            simd_float4(0.0, 1.0, 0.0, 0.0),
            simd_float4(0.0, 0.0, 1.0, 0.0),
            simd_float4(1.0, 1.0, 1.0, 1.0)
        )
        let previousFramePose = simd_float4x4(
            simd_float4(1.0, 0.0, 0.0, 0.0),
            simd_float4(0.0, 1.0, 0.0, 0.0),
            simd_float4(0.0, 0.0, 1.0, 0.0),
            simd_float4(0.0, 0.0, 0.0, 1.0)
        )
        
        
        let distance = model.calculatePoseAngle(currentFramePose: currentFramePose, previousFramePose: previousFramePose)
        print("distance \(distance)")
        XCTAssertEqual(distance, 0, accuracy: 0.0001, "Angle calculation is incorrect")
    }
    
    func testCalculatePoseAngleDifference2() throws {
        let angle = Float.pi / 2
        let currentFramePose = simd_float4x4(
            simd_float4(cos(angle), 0.0, sin(angle), 0.0),
            simd_float4(0.0, 1.0, 0.0, 0.0),
            simd_float4(-sin(angle), 0.0, cos(angle), 0.0),
            simd_float4(1.0, 1.0, 1.0, 1.0)
        )
        let previousFramePose = simd_float4x4(
            simd_float4(1.0, 0.0, 0.0, 0.0),
            simd_float4(0.0, 1.0, 0.0, 0.0),
            simd_float4(0.0, 0.0, 1.0, 0.0),
            simd_float4(0.0, 0.0, 0.0, 1.0)
        )
        
        let angleDiff = model.calculatePoseAngle(currentFramePose: currentFramePose, previousFramePose: previousFramePose)
        let expectedAngleDiff = Float.pi / 2
        
        XCTAssertEqual(angleDiff, expectedAngleDiff, accuracy: 0.0001, "Angle calculation is incorrect")
    }
    
    func testCalculatePoseAngleDifference3() throws {
        let angle = Float.pi / 2 + 2 * Float.pi
        let currentFramePose = simd_float4x4(
            simd_float4(cos(angle), 0.0, sin(angle), 0.0),
            simd_float4(0.0, 1.0, 0.0, 0.0),
            simd_float4(-sin(angle), 0.0, cos(angle), 0.0),
            simd_float4(1.0, 1.0, 1.0, 1.0)
        )
        let previousFramePose = simd_float4x4(
            simd_float4(1.0, 0.0, 0.0, 0.0),
            simd_float4(0.0, 1.0, 0.0, 0.0),
            simd_float4(0.0, 0.0, 1.0, 0.0),
            simd_float4(0.0, 0.0, 0.0, 1.0)
        )
        
        let angleDiff = model.calculatePoseAngle(currentFramePose: currentFramePose, previousFramePose: previousFramePose)
        let expectedAngleDiff = Float.pi / 2
        
        XCTAssertEqual(angleDiff, expectedAngleDiff, accuracy: 0.0001, "Angle calculation is incorrect")
    }
    
    func testCalculatePoseAngleDifference4() throws {
        let angle = -(Float.pi / 4)
        let currentFramePose = simd_float4x4(
            simd_float4(cos(angle), 0.0, sin(angle), 0.0),
            simd_float4(0.0, 1.0, 0.0, 0.0),
            simd_float4(-sin(angle), 0.0, cos(angle), 0.0),
            simd_float4(1.0, 1.0, 1.0, 1.0)
        )
        let previousFramePose = simd_float4x4(
            simd_float4(1.0, 0.0, 0.0, 0.0),
            simd_float4(0.0, 1.0, 0.0, 0.0),
            simd_float4(0.0, 0.0, 1.0, 0.0),
            simd_float4(0.0, 0.0, 0.0, 1.0)
        )
        
        let angleDiff = model.calculatePoseAngle(currentFramePose: currentFramePose, previousFramePose: previousFramePose)
        let expectedAngleDiff = Float.pi / 4
        
        XCTAssertEqual(angleDiff, expectedAngleDiff, accuracy: 0.0001, "Angle calculation is incorrect")
    }
    
    func testCreateProjectFolder() throws {
        // Call the function being tested
        model.createProjectFolder()
        
        // Get a file manager and the expected file URL
        let fileManager = FileManager.default
        let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(model.uuid.uuidString)
        
        // Check that the folder exists
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)
        XCTAssertTrue(exists && isDirectory.boolValue)
    }
    
    func testCreateProjectJson() throws{
        model.createProjectFolder()
        model.createProjectJson()
        let fileManager = FileManager.default
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(model.uuid.uuidString)
        let jsonFileURL = fileURL.appendingPathComponent("info.json")
        XCTAssertTrue(fileManager.fileExists(atPath: jsonFileURL.path))
        
        // Check the contents of the JSON file
            let jsonData = try Data(contentsOf: jsonFileURL)
            guard let projectInfo = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                XCTFail("Could not parse JSON data")
                return
            }
            
            // Check the "owner" key
            guard let owner = projectInfo["owner"] as? String else {
                XCTFail("Missing or invalid \"owner\" key in JSON data")
                return
            }
            XCTAssertEqual(owner, "default")
            
            // Check the "frameCount" key
            guard let frameCount = projectInfo["frameCount"] as? String else {
                XCTFail("Missing or invalid \"frameCount\" key in JSON data")
                return
            }
            XCTAssertEqual(frameCount, "0")
    }
        
    
    
    

    
    
}
