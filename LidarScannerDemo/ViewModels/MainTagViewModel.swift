//
//  MainTagViewModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/8.
//

import Foundation
import Combine

class MainTagViewModel: ObservableObject {
    @Published var captures = [CapturePreviewModel]()

    var selectedCaptureUUID: UUID?
    var isSelectedCaptureProcessed: Bool?
    
    init(captures: [CapturePreviewModel] = []) {
        self.captures = captures
        loadCaptures()
    }
    
    func selectCapture(uuid: UUID){
        print("glb的时候进入了这里，uuid == == ==",uuid)
        self.selectedCaptureUUID = uuid
        if let selectedCapture = captures.first(where: { $0.id == uuid }) {
                print("selectedCapture不为空")
                self.isSelectedCaptureProcessed = selectedCapture.isProcessed
                print("self.isSelectedCaptureProcessed == == ==",self.isSelectedCaptureProcessed)
            
            } else {
                print("selectedCapture为空")
                self.isSelectedCaptureProcessed = false
            }
    }

    func loadCaptures() {
        DispatchQueue.main.async {
            self.captures.removeAll()
        }
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        var tempCaptures = [CapturePreviewModel]()
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            let directories = directoryContents.filter({ $0.hasDirectoryPath })
            for directory in directories {
                if let uuid = UUID(uuidString: directory.lastPathComponent) {
                    let attributes = try fileManager.attributesOfItem(atPath: directory.path)
                    let creationDate = attributes[.creationDate] as? Date ?? Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = NSLocalizedString("capture_preview_date_fromat", comment: "")
                    let dateString = formatter.string(from: creationDate)
                    let previewImageURL = directory.appendingPathComponent("cover.png")
                    
                    
                    ///1118-16:19修改
                    //let texturedMeshName = "textured.obj"
                    //let texturedMeshName : String
                    //let texturedMeshPath = documentsDirectory.appendingPathComponent("\(uuid.uuidString)/textured/\(texturedMeshName)").path
                    
//                    if FileManager.default.fileExists(atPath: documentsDirectory.appendingPathComponent("\(uuid.uuidString)/textured/\(uuid.uuidString.lowercased()).glb").path) {
//                        texturedMeshName = "\(uuid.uuidString.lowercased()).glb"
//                    } else {
//                        texturedMeshName = "textured.obj"
//                    }
                    
                    let texturedMeshPath:String
                    if FileManager.default.fileExists(atPath: documentsDirectory.appendingPathComponent("\(uuid.uuidString)/textured/\(uuid.uuidString.lowercased()).glb").path) {
                        texturedMeshPath = documentsDirectory.appendingPathComponent("\(uuid.uuidString)/textured/\(uuid.uuidString.lowercased()).glb").path
                    }
                    else if FileManager.default.fileExists(atPath: documentsDirectory.appendingPathComponent("\(uuid.uuidString)/textured/textured.obj").path)
                    {
                        texturedMeshPath = documentsDirectory.appendingPathComponent("\(uuid.uuidString)/textured/textured.obj").path
                    }
                    else
                    {
                        texturedMeshPath = documentsDirectory.appendingPathComponent("\(uuid.uuidString)/textured/mesh.obj").path
                    }
                    
                    
                    let isProcessed = fileManager.fileExists(atPath: texturedMeshPath)
                    let newCapture = CapturePreviewModel(id: uuid, dateString: dateString, date: creationDate, previewImageURL: previewImageURL, isProcessed: isProcessed)
                    tempCaptures.append(newCapture)
                }
            }
            let sortedCaptures = tempCaptures.sorted { $0.date > $1.date }
            DispatchQueue.main.async {
                self.captures = sortedCaptures
            }
        } catch {
        }
    }
}

