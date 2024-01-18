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
    
    init(captures: [CapturePreviewModel] = []) {
        self.captures = captures
        loadCaptures()
    }
    
    func selectCapture(uuid: UUID){
        self.selectedCaptureUUID = uuid
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
                    let newCapture = CapturePreviewModel(id: uuid, dateString: dateString, date: creationDate, previewImageURL: previewImageURL)
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

