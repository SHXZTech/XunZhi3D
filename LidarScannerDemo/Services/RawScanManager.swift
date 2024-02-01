//
//  RawScanManager.swift
//  SwitchCameraTutorial
//
//  Created by Tao Hu on 2023/4/21.
//

import Foundation
import ARKit
import SceneKit
import Zip

class RawScanManager{
    
    @Published var raw_scan_model: RawScanModel
    var cloud_service: CloudService
    
    
    init(uuid:UUID){
        self.raw_scan_model = RawScanModel(id_:uuid)
        self.cloud_service = CloudService()
    }
    
    func deleteProjectFolder(){
        self.raw_scan_model.deleteScanFolder()
    }
    
    func isRawMeshExist() -> Bool{
        return raw_scan_model.isRawMeshExist
    }
    
    func getRawObjURL()-> URL{
       return raw_scan_model.getRawObjURL()
    }
    
    func getRawMeshURL()-> URL{
        return raw_scan_model.rawMeshURL ?? raw_scan_model.getRawMeshURL()
    }
    
    func uploadCapture(completion: @escaping (Bool, String) -> Void) {
        zipCapture { zipResult in
            switch zipResult {
            case .success(let zipFileURL):
                self.cloud_service.uploadCapture(uuid: self.raw_scan_model.id, fileURL: zipFileURL, progressHandler: { progressValue in
                    DispatchQueue.main.async {
                        self.raw_scan_model.cloudStatus = .uploading
                        self.raw_scan_model.uploadingProgress = progressValue
                        print("self.raw_scan_model.uploadingProgress = ", progressValue)
                    }
                }, completion: { result in
                    switch result {
                    case .success(_):
                        DispatchQueue.main.async {
                            self.raw_scan_model.cloudStatus = .uploaded
                            completion(true, "Upload successful")
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            completion(false, "Upload failed: \(error.localizedDescription)")
                        }
                    }
                })
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(false, "Zipping failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func createCloudCapture(completion: @escaping (Bool) -> Void) {
        cloud_service.createCapture(uuid: self.raw_scan_model.id) { createResult in
            DispatchQueue.main.async {
                switch createResult {
                case .success(_):
                    completion(true)
                case .failure(_):
                    completion(false)
                }
            }
        }
    }
    
    func checkstatusAndUpload(){
        print("start checkstatusAndUpload()")
        loadCloudStatus()
        print("current status = ", raw_scan_model.cloudStatus)
        if raw_scan_model.cloudStatus == .not_created{
            self.createCloudCapture(completion: { success in
                if success {
                    self.raw_scan_model.cloudStatus = .uploaded
                    self.uploadCapture(completion: { success, message in
                        if success {
                            self.raw_scan_model.cloudStatus = .uploaded
                        } else {
                            self.raw_scan_model.cloudStatus = .wait_upload
                        }
                    })
                }
            })
        }else{
            self.raw_scan_model.cloudStatus = .uploading
            self.uploadCapture(completion: { success, message in
                if success {
                    self.raw_scan_model.cloudStatus = .uploaded
                } else {
                    self.raw_scan_model.cloudStatus = .wait_upload
                }
            })
        }
    }
    
    func loadCloudStatus() {
        cloud_service.getCaptureStatus(uuid: raw_scan_model.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let statusResponse):
                    switch statusResponse.status{
                    case 0:
                        DispatchQueue.main.async {
                            self.raw_scan_model.cloudStatus = .wait_upload
                        }
                        break;
                    case 1:
                        DispatchQueue.main.async {
                            self.raw_scan_model.cloudStatus = .uploading
                        }
                        break;
                    case 2:
                        DispatchQueue.main.async {
                            self.raw_scan_model.cloudStatus = .uploaded
                        }
                        break;
                    case 3:
                        DispatchQueue.main.async {
                            self.raw_scan_model.cloudStatus = .wait_process
                        }
                        break;
                    case 4:
                        DispatchQueue.main.async {
                            self.raw_scan_model.cloudStatus = .processing
                        }
                        break;
                    case 5:
                        DispatchQueue.main.async {
                            self.raw_scan_model.cloudStatus = .processed
                        }
                        break;
                    case 6:
                        DispatchQueue.main.async {
                            self.raw_scan_model.cloudStatus = .downloading
                        }
                        break;
                    case 7:
                        DispatchQueue.main.async {
                            self.raw_scan_model.cloudStatus = .downloaded
                        }
                        break;
                    case 100:
                        DispatchQueue.main.async {
                            self.raw_scan_model.cloudStatus = .not_created
                        }
                        break;
                    case -1:
                        DispatchQueue.main.async {
                            self.raw_scan_model.cloudStatus = .process_failed
                        }
                        break;
                    default:
                        DispatchQueue.main.async {
                            self.raw_scan_model.cloudStatus = nil
                        }
                        break
                    }
                case .failure(_):
                    self.raw_scan_model.cloudStatus = nil
                }
            }
        }
    }
    
}


extension RawScanManager {
    func zipCapture(completion: @escaping (Result<URL, Error>) -> Void) {
        let scan_folder = raw_scan_model.scanFolder
        guard let zipFileURL = raw_scan_model.zipFileURL else{
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
