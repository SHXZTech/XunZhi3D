//
//  FrameJsonInfo.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/5/10.
//

import Foundation
import RealityKit
import ARKit
import SceneKit
import os

/*
 Description: Save scanning data to local with this struct.
                
 
 */
struct FrameJsonInfo{
    var timestamp: TimeInterval
    
    var dataFolder: URL
    var infoJsonURL: URL
    var totalFrame: Int
    var intrinsic: simd_float3x3
    var transform: simd_float4x4
    
   
    
    
    
    
   
}
