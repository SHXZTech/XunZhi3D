//
//  CapturePreviewModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/7.
//

import Foundation

struct CapturePreviewModel: Identifiable {
    var id: UUID
    var dateString: String
    var date: Date
    var previewImageURL: URL
    var isProcessed: Bool
}
