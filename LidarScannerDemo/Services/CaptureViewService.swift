//
//  CaptureViewService.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/15.
//

import Foundation
import ARKit
import SceneKit

struct CaptureViewService{
    
    public var captureModel: CaptureModel
    init(id_:UUID)
    {
        self.captureModel = CaptureModel(id:id_)
        captureModel.id = id_
        loadCaptureModel()
    }
    
    private mutating func loadCaptureModel(){
        captureModel.scanFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(captureModel.id.uuidString)
        loadFolderSize()
        loadCaptureJson()
    }
    
    private mutating func loadCaptureJson(){
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let jsonURL = documentsDirectory.appendingPathComponent("\(captureModel.id.uuidString)/info.json")
        let id = captureModel.id
        do {
            let jsonData = try Data(contentsOf: jsonURL)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            if let jsonDict = jsonObject as? [String: Any] {
                captureModel.isExist = isExistCheck()
                if let configs = jsonDict["configs"] as? [[String: Any]] {
                    if configs.contains(where: { $0["isMeshModel"] as? Bool == true }) {
                        let meshModelDict = configs.first(where: { $0.keys.contains("MeshModelName") })
                        if let rawMeshName = meshModelDict?["MeshModelName"] as? String {
                            let rawMeshPath = documentsDirectory.appendingPathComponent("\(id.uuidString)/\(rawMeshName)").path
                            captureModel.isRawMeshExist = fileManager.fileExists(atPath: rawMeshPath)
                            if captureModel.isRawMeshExist {
                                captureModel.rawMeshURL = URL(fileURLWithPath: rawMeshPath)
                            }
                        }
                    }
                }
                if let rtkDataArray = jsonDict["rtkData"] as? [[String: Any]] {
                       var rtkObjects = [RTKdata]()
                       for rtkEntry in rtkDataArray {
                           let longitude = Double(rtkEntry["longitude"] as? String ?? "") ?? 0.0
                           let latitude = Double(rtkEntry["latitude"] as? String ?? "") ?? 0.0
                           let rtkData = RTKdata(
                               longitude: longitude,
                               latitude: latitude,
                               horizontalAccuracy: Double(rtkEntry["horizontalAccuracy"] as? String ?? "") ?? 0.0,
                               verticalAccuracy: Double(rtkEntry["verticalAccuracy"] as? String ?? "") ?? 0.0,
                               fixStatus: Int(rtkEntry["fixStatus"] as? Int ?? 0),
                               height: rtkEntry["height"] as? Double ?? 0.0,
                               timeStamp: convertUnixTimeStampToDate(rtkEntry["timeStamp"] as? Double),
                               GpsLocations: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                           )
                           rtkObjects.append(rtkData)
                       }
                       captureModel.rtkDataArray = rtkObjects
                   }
                
                if let configs = jsonDict["configs"] as? [[String: Any]] {
                    for config in configs {
                        if let createDateStr = config["createDate"] as? String {
                            captureModel.createDate = convertStringToDate(createDateStr)
                            break // Assuming only one createDate in configs
                        }
                    }
                }
                captureModel.isDepth = (jsonDict["configs"] as? [[String: Any]])?.contains(where: { $0["isDepthEnable"] as? Bool == true }) ?? false
                captureModel.isPose = (jsonDict["configs"] as? [[String: Any]])?.contains(where: { ($0["isIntrinsicEnable"] as? Bool == true) || ($0["isExtrinsicEnable"] as? Bool == true) }) ?? false
                captureModel.isGPS = (jsonDict["configs"] as? [[String: Any]])?.contains(where: { $0["isGPSEnable"] as? Bool == true }) ?? false
                captureModel.isRTK = (jsonDict["configs"] as? [[String: Any]])?.contains(where: { $0["isRTKEnable"] as? Bool == true }) ?? false
                captureModel.frameCount = (jsonDict["frameCount"] as? Int) ?? 0
            }
        } catch {
        }
    }
    
    private func convertUnixTimeStampToDate(_ timeStamp: Double?) -> Date {
        guard let timeStamp = timeStamp else { return Date() }
        return Date(timeIntervalSince1970: timeStamp)
    }
    
    private mutating func loadFolderSize(){
        captureModel.totalSize = calculateFolderSize(folderURL: captureModel.scanFolder!)
    }
    
    private func convertStringToDate(_ string: String?) -> Date {
        guard let string = string else { return Date() }
        let formatter = DateFormatter()
        // Adjust the date format according to the format used in your JSON
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: string) ?? Date()
    }
    
    func loadCloudStatus(){
        //TODO
        //case upload, uploading, processing, download, downloading, downloaded
        // upload? // getfrom remote
        
        // uploading? // decide local
        
        //processing? // getfrom remote
        
        // download? // getfrom remote
        
        // downloading? // decide local
        
        // downloaded // decide local
    }

    func getProjectSize() -> Int64? {
        return captureModel.totalSize
    }

    private func isExistCheck() -> Bool {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderURL = documentsDirectory.appendingPathComponent(captureModel.id.uuidString)
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: folderURL.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    func deleteScanFolder() {
        deleteFolder(folderURL: captureModel.scanFolder!)
    }
    
    func isRawMeshExist() -> Bool{
        return captureModel.isRawMeshExist
    }
    
    func getRawMeshURL() -> URL? {
        return captureModel.rawMeshURL
    }
    
    func getObjModelURL() -> URL?{
        return captureModel.objModelURL
    }
    
    func getProjectCreationDate() -> Date? {
        if let createDate = captureModel.createDate {
            return createDate
        } else if let folderURL = captureModel.scanFolder {
            return getFolderCreateDate(folderURL: folderURL)
        } else {
            return nil
        }
    }

}
