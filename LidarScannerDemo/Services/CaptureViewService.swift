//
//  CaptureViewService.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/15.
//

import Foundation
import ARKit
import SceneKit
import Zip

class CaptureViewService: ObservableObject{
    
    @Published var captureModel: CaptureModel
    @Published var updateSyncedModel: Bool
    var uploadcapture_lock:Bool
    var cloudStatusCheckTimer: Timer?
    var cloud_service: CloudService
    init(id_:UUID)
    {
        self.captureModel = CaptureModel(id:id_)
        self.cloud_service = CloudService()
        self.updateSyncedModel = false;
        self.uploadcapture_lock = false;
        captureModel.id = id_
        loadCaptureModel()
        loadCloudStatus()
        startCloudStatusCheckTimer()
    }
    
    private func startCloudStatusCheckTimer() {
        // Check if the timer already exists. If it does, return and do not create a new one.
        guard cloudStatusCheckTimer == nil else { return }
        // Create and schedule a new timer
        cloudStatusCheckTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // Check if the current cloud status is .downloaded, in which case the timer can be stopped
            if self.captureModel.cloudStatus == .downloaded {
                self.stopCloudStatusCheckTimer()
                return
            }
                self.loadCloudStatus()
        }
    }

    private func stopCloudStatusCheckTimer() {
        cloudStatusCheckTimer?.invalidate()
        cloudStatusCheckTimer = nil
    }

    
    
    private func loadCaptureModel(){
        captureModel.scanFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(captureModel.id.uuidString)
        captureModel.zipFileURL = captureModel.scanFolder?.appendingPathComponent(captureModel.id.uuidString+".zip")
        loadFolderSize()
        loadCaptureJson()
    }
    
    private func loadCaptureJson(){
        // change load the capture.rtkdataarray from rtk folder
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
                    let rawMeshName = "mesh.obj"
                    let rawMeshPath = documentsDirectory.appendingPathComponent("\(id.uuidString)/\(rawMeshName)").path
                    captureModel.isRawMeshExist = fileManager.fileExists(atPath: rawMeshPath)
                    if captureModel.isRawMeshExist {
                        captureModel.rawMeshURL = URL(fileURLWithPath: rawMeshPath)
                        captureModel.objModelURL = URL(fileURLWithPath: rawMeshPath)
                    }
                    let texturedMeshName = "textured.obj"
                    let texturedMeshPath = documentsDirectory.appendingPathComponent("\(id.uuidString)/textured/\(texturedMeshName)").path
                    captureModel.isTexturedMeshExist = fileManager.fileExists(atPath: texturedMeshPath)
                    if captureModel.isTexturedMeshExist{
                        captureModel.texturedObjURL = URL(fileURLWithPath: texturedMeshPath)
                    }
                    
                }
                if let configs = jsonDict["configs"] as? [[String: Any]] {
                    for config in configs {
                        if let createDateStr = config["createDate"] as? String {
                            captureModel.createDate = convertStringToDate(createDateStr)
                        }
                        if let latitude = config["latitude"] as? Double, latitude > 0 {
                            captureModel.createLat = String(latitude)
                        }
                        if let longitude = config["longitude"] as? Double, longitude > 0 {
                            captureModel.createLon = String(longitude)
                        }
                        if let height = config["height"] as? Double, height > 0 && height < 10000 {
                            captureModel.createHeight = String(height)
                        }
                        if let horizontalAccuracy = config["horizontalAccuracy"] as? Double,
                           horizontalAccuracy > 0 && horizontalAccuracy < 100 {
                            captureModel.minHorizontalAccuracy = Float(horizontalAccuracy)
                        }
                        if let verticalAccuracy = config["verticalAccuracy"] as? Double,
                           verticalAccuracy > 0 && verticalAccuracy < 100 {
                            captureModel.minHorizontalAccuracy = Float(verticalAccuracy) // Should this be minVerticalAccuracy?
                        }
                    }
                }
                captureModel.isDepth = (jsonDict["configs"] as? [[String: Any]])?.contains(where: { $0["isDepthEnable"] as? Bool == true }) ?? false
                captureModel.isPose = (jsonDict["configs"] as? [[String: Any]])?.contains(where: { ($0["isIntrinsicEnable"] as? Bool == true) || ($0["isExtrinsicEnable"] as? Bool == true) }) ?? false
                captureModel.isGPS = (jsonDict["configs"] as? [[String: Any]])?.contains(where: { $0["isGpsEnable"] as? Bool == true }) ?? false
                captureModel.isRTK = (jsonDict["configs"] as? [[String: Any]])?.contains(where: { $0["isRtkEnable"] as? Bool == true }) ?? false
                captureModel.frameCount = (jsonDict["frameCount"] as? Int) ?? 0
            }
        } catch {
        }
    }
    
    func checkTexturedExist()-> Bool{
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let texturedMeshPath = documentsDirectory.appendingPathComponent("\(self.captureModel.id.uuidString)/textured/textured.obj").path
        captureModel.isTexturedMeshExist = fileManager.fileExists(atPath: texturedMeshPath)
        if captureModel.isTexturedMeshExist{
            captureModel.texturedObjURL = URL(fileURLWithPath: texturedMeshPath)
            return true;
        }
        else{ return false;}
    }
    
    private func convertUnixTimeStampToDate(_ timeStamp: Double?) -> Date {
        guard let timeStamp = timeStamp else { return Date() }
        return Date(timeIntervalSince1970: timeStamp)
    }
    
    private func loadFolderSize(){
        captureModel.totalSize = calculateFolderSize(folderURL: captureModel.scanFolder!)
    }
    
    private func convertStringToDate(_ string: String?) -> Date {
        guard let string = string else { return Date() }
        let formatter = DateFormatter()
        // Adjust the date format according to the format used in your JSON
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: string) ?? Date()
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
        checkTexturedExist()
        if self.captureModel.isTexturedMeshExist{
            return captureModel.texturedObjURL
        }else{
            return captureModel.objModelURL}
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
    
    func loadCloudStatus() {
        if self.captureModel.isTexturedMeshExist{
            self.captureModel.cloudStatus = .downloaded
            return
        }
        cloud_service.getCaptureStatus(uuid: captureModel.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let statusResponse):
                    switch statusResponse.status{
                    case 0:
                        self.captureModel.cloudStatus = .wait_upload
                        self.captureModel.cloudStatus = .uploading
                        if (self.uploadcapture_lock == true){
                            return
                        }
                        self.uploadcapture_lock = true
                        self.uploadCapture(completion: { success, message in
                            if success {
                                self.captureModel.cloudStatus = .uploaded
                                self.startCloudStatusCheckTimer()
                                self.uploadcapture_lock = false
                            }
                            else{
                                self.captureModel.cloudStatus = .wait_upload
                                self.stopCloudStatusCheckTimer()
                                self.uploadcapture_lock = false
                            }
                        })
                        break;
                    case 1:
                        self.captureModel.cloudStatus = .uploading
                        break;
                    case 2:
                        self.captureModel.cloudStatus = .uploaded
                       
                        break;
                    case 3:
                        self.captureModel.cloudStatus = .wait_process
                        self.startCloudStatusCheckTimer()
                        break;
                    case 4:
                        self.captureModel.cloudStatus = .processing
                        self.startCloudStatusCheckTimer()
                        break;
                    case 5:
                        self.captureModel.cloudStatus = .processed
                        if self.checkTexturedExist(){
                            self.captureModel.cloudStatus = .downloaded
                            self.loadCloudStatus()
                            self.stopCloudStatusCheckTimer()
                            break;
                        }
                        self.captureModel.cloudStatus = .downloading
                        self.downloadTexture(completion: { success, message in
                            if success {
                                self.captureModel.cloudStatus = .downloaded
                                self.stopCloudStatusCheckTimer()
                                self.updateSyncedModel = true;
                            } else {
                                self.captureModel.cloudStatus = .processed
                                self.stopCloudStatusCheckTimer()
                            }
                        })
                        break;
                    case 6:
                        self.captureModel.cloudStatus = .downloading
                        break;
                    case 7:
                        self.captureModel.cloudStatus = .downloaded
                        self.stopCloudStatusCheckTimer()
                        break;
                    case 100:
                        self.captureModel.cloudStatus = .not_created
                        self.captureModel.cloudStatus = .uploading
                        self.createCloudCapture(completion: { success in
                            if success {
                                self.captureModel.cloudStatus = .uploaded
                                self.uploadCapture(completion: { success, message in
                                    if success {
                                        self.captureModel.cloudStatus = .uploaded
                                        self.startCloudStatusCheckTimer()
                                    } else {
                                        self.captureModel.cloudStatus = .wait_upload
                                        self.stopCloudStatusCheckTimer()
                                    }
                                })
                            }
                        })
                        break;
                    case -1:
                        self.captureModel.cloudStatus = .process_failed
                        self.stopCloudStatusCheckTimer()
                        break;
                    default:
                        self.captureModel.cloudStatus = nil
                        break
                    }
                    
                case .failure(_):
                    self.captureModel.cloudStatus = nil
                    self.stopCloudStatusCheckTimer()
                }
            }
        }
    }
    
    
    func createCloudCapture(completion: @escaping (Bool) -> Void) {
        cloud_service.createCapture(uuid: self.captureModel.id) { createResult in
            DispatchQueue.main.async {
                switch createResult {
                case .success(let createResponse):
                    completion(true)
                case .failure(let createError):
                    completion(false)
                }
            }
        }
    }
    
    func downloadTexture(completion: @escaping (Bool, String) -> Void) {
        
        guard let scanFolder = captureModel.scanFolder else {
            completion(false, "scanFolder not exist")
            return
        }
        let destinationFileURL = scanFolder.appendingPathComponent("textured.zip")
        let textureExtractDestinationURL = scanFolder.appendingPathComponent("textured")
        cloud_service.downloadTexture(uuid: self.captureModel.id, to: destinationFileURL) { result in
            switch result {
            case .success(_):
                do {
                    try FileManager.default.createDirectory(at: textureExtractDestinationURL, withIntermediateDirectories: true, attributes: nil)
                    try Zip.unzipFile(destinationFileURL, destination: textureExtractDestinationURL, overwrite: true, password: nil, progress: nil)
                    completion(true, "File downloaded and extracted successfully: \(textureExtractDestinationURL.path)")
                } catch {
                    completion(false, "Failed to extract file: \(error.localizedDescription)")
                }
            case .failure(let error):
                completion(false, "Error downloading file: \(error.localizedDescription)")
            }
        }
    }
    
    func uploadCapture(completion: @escaping(Bool, String)->Void){
        zipCapture{ zipResult in
            switch zipResult {
            case .success(let zipFileURL):
                self.cloud_service.uploadCapture(uuid: self.captureModel.id, fileURL: zipFileURL) { uploadResult in
                    switch uploadResult {
                    case .success(let uploadResponse):
                        self.captureModel.cloudStatus = .processing
                        completion(true, "Upload success")
                        
                    case .failure(let uploadError):
                        completion(false, "Upload fail")
                    }
                }
            case .failure(let zipError):
                completion(false, "Upload fail")
            }
        }
    }
    
}

extension String {
    func removingPrefix(_ prefix: String) -> String? {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

extension CaptureViewService {
    func zipCapture(completion: @escaping (Result<URL, Error>) -> Void) {
        guard let scan_folder = captureModel.scanFolder else {
            completion(.failure(CaptureViewServiceError.folderNotFound))
            return
        }
        guard let zipFileURL = captureModel.zipFileURL else{
            completion(.failure(CaptureViewServiceError.folderNotFound))
            return
        }
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: zipFileURL.path) {
                try fileManager.removeItem(at: zipFileURL)
            }
            try Zip.zipFiles(paths: [scan_folder], zipFilePath: zipFileURL, password: nil, progress: nil)
            completion(.success(zipFileURL))
        } catch {
            completion(.failure(error))
        }
    }
    
}

enum CaptureViewServiceError: Error {
    case folderNotFound
    // Define other errors as needed
}
