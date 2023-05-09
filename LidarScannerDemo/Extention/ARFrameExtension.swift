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
            let depthImage = CIImage( cvImageBuffer: depthPixelBufferTemp,options: [ .auxiliaryDepth: true ] )
            let context = CIContext(options: nil)
            if let colorSpace = CGColorSpace(name: CGColorSpace.linearGray), let depthMapData = context.tiffRepresentation(of: depthImage, format: .Lf, colorSpace: colorSpace, options: [.depthImage: depthImage ]){
                return depthMapData
            }else{
                return nil
            }
        }
        return nil
    }
    
    
    
    func lidarConfidenceData()-> Data?{
        var confidencePixelBuffer: CVPixelBuffer? = nil
        if let smoothconfidenceMap = self.smoothedSceneDepth?.confidenceMap {
            confidencePixelBuffer = smoothconfidenceMap
        } else {
            if let confidenceMap = self.sceneDepth?.confidenceMap{
                confidencePixelBuffer = confidenceMap}
            else{
                return nil;
            }
        }
        if let confidencePixelBufferTemp = confidencePixelBuffer {
            let confidenceImage = CIImage( cvImageBuffer: confidencePixelBufferTemp,options: [:])
            let context = CIContext(options: nil)
            if let colorSpace = CGColorSpace(name: CGColorSpace.extendedLinearGray), let confidenceMapData = context.tiffRepresentation(of: confidenceImage, format: .L8, colorSpace: colorSpace){
                return confidenceMapData
            }else{
                return nil
            }
        }
        return nil
    //SLEEP: the depth image should be like single, the confidence map is wrong
    }
}
