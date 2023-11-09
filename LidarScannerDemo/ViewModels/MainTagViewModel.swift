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

    init(captures: [CapturePreviewModel] = []) {
        self.captures = captures
        loadCaptures()
    }

    func loadCaptures() {
        // Ensure we are on the main thread since we are updating the UI
        DispatchQueue.main.async {
            self.captures.removeAll()
        }

        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            let directories = directoryContents.filter({ $0.hasDirectoryPath })

            for directory in directories {
                // Extract the UUID from the folder name
                if let uuid = UUID(uuidString: directory.lastPathComponent) {
                    // Attempt to get the creation date of the folder
                    let attributes = try fileManager.attributesOfItem(atPath: directory.path)
                    let creationDate = attributes[.creationDate] as? Date ?? Date()
                    
                    // Format the date into a string
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    formatter.timeStyle = .short
                    let dateString = formatter.string(from: creationDate)
                    
                    // Here, we're assuming a fixed image name (e.g., "preview.jpg"),
                    // you will need to adjust this to your actual image retrieval logic.
                    let previewImageURL = directory.appendingPathComponent("cover.jpeg")

                    
                    // Create and append the new capture
                    let newCapture = CapturePreviewModel(id: uuid, date: dateString, previewImageURL: previewImageURL)
                    DispatchQueue.main.async {
                        self.captures.append(newCapture)
                    }
                }
            }
        } catch {
            print("Error reading contents of documents directory: \(error)")
        }
    }

    // ... other functions
}

