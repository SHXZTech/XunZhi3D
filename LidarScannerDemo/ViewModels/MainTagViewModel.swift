//
//  MainTagViewModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/8.
//

import Foundation
import Combine

class MainTagViewModel: ObservableObject {
    @Published var captures: [CapturePreviewModel]

    // Allow initialization with a specific set of captures
    init(captures: [CapturePreviewModel] = []) {
        self.captures = captures
        loadCaptures()
    }

    func loadCaptures() {
        // Load captures if not provided during initialization
        if captures.isEmpty {
            // Simulate loading of captures, this is where your data fetching logic would go
            self.captures = [
                // Default data to load if none is provided during initialization
            ]
        }
    }
    
    // ... other functions
}
