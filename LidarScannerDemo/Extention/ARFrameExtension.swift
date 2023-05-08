//
//  ARFrameExtension.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/5/4.
//

import Foundation
import ARKit

extension ARFrame {
    func capturedjpegData() -> Data? {
        let pixelBuffer = self.capturedImage
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let RGBimage = UIImage(cgImage: cgImage)
            let data = RGBimage.jpegData(compressionQuality: 1.0)
            return data
        }
        return nil
    }
    
     func lidarDepthData()-> Data?{
        //priority select smoothdepthdata then scenedepth
        var depthPixelBuffer: CVPixelBuffer? = nil
        if let smoothDepthMap = self.smoothedSceneDepth?.depthMap {
            depthPixelBuffer = smoothDepthMap
        } else {
            if let depthMap = self.sceneDepth?.depthMap{
                depthPixelBuffer = depthMap}
            else{
                return nil;
            }
        }
        if let depthPixelBufferTemp = depthPixelBuffer {
            let ciImage = CIImage(cvPixelBuffer: depthPixelBufferTemp)
            let context = CIContext(options: nil)
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                let RGBimage = UIImage(cgImage: cgImage)
                let data = RGBimage.pngData()
                return data
            }
        } else {
            return nil
        }
        return nil
    }


    
    func lidarConfidenceData()-> Data?{
        var depthPixelBuffer: CVPixelBuffer? = nil
        if let smoothDepthMap = self.smoothedSceneDepth?.confidenceMap {
            depthPixelBuffer = smoothDepthMap
        } else {
            if let depthMap = self.sceneDepth?.confidenceMap{
                depthPixelBuffer = depthMap}
            else{
                return nil;
            }
        }
        if let depthPixelBufferTemp = depthPixelBuffer {
            let ciImage = CIImage(cvPixelBuffer: depthPixelBufferTemp)
            let context = CIContext(options: nil)
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                let RGBimage = UIImage(cgImage: cgImage)
                let data = RGBimage.pngData()
                return data
            }
        } else {
            return nil
        }
        return nil
    }
}
