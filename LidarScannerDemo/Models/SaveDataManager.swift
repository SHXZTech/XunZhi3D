//
//  SaveDataManager.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/5/12.
//


import Foundation
import RealityKit
import ARKit
import SceneKit
import os

private let logger = Logger(subsystem: "com.graphopti.lidarScannerDemo",
                            category: "lidarScannerDemoDelegate")

func savePngData(pngData: Data,fileFolder: URL,timeStamp:String,type:String?)-> String{
    //let fileName = (type ?? "IMG") + "_" + String(format: "%.5f", timeStamp) + ".png"
    let fileName = timeStamp + ".png"
    let fileURL = fileFolder.appendingPathComponent(fileName)
    let directory = fileURL.deletingLastPathComponent()
    do {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    } catch let error {
        return "";
    }
    do {
        try pngData.write(to: fileURL)
        return fileName;
    } catch {
        return "";
    }
}

func saveTiffData(tiffData: Data,fileFolder: URL,timeStamp:String,type:String?)-> String{
    //let fileName = (type ?? "IMG") + "_" + String(format: "%.5f", timeStamp) + ".TIF"
    let fileName = timeStamp + ".TIF"
    let fileURL = fileFolder.appendingPathComponent(fileName)
    let directory = fileURL.deletingLastPathComponent()
    do {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    } catch let error {
        
        return "";
    }
    do {
        try tiffData.write(to: fileURL)
        return fileName;
    } catch {
        return "";
    }
}


func saveJpegData(jpegData: Data,fileFolder: URL,timeStamp:String,type:String?)-> String{
    let fileName = timeStamp + ".jpeg"
    let fileURL = fileFolder.appendingPathComponent(fileName)
    let directory = fileURL.deletingLastPathComponent()
    do {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    } catch let error {
        logger.error("Error creating directory: \(error.localizedDescription)")
        return "";
    }
    do {
        try jpegData.write(to: fileURL)
        return fileName;
    } catch {
        return "";
    }
}


func saveJpgData(jpegData: Data,fileFolder: URL,timeStamp:String,type:String?)-> String{
    let fileName = timeStamp + ".jpg"
    let fileURL = fileFolder.appendingPathComponent(fileName)
    let directory = fileURL.deletingLastPathComponent()
    do {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    } catch let error {
        logger.error("Error creating directory: \(error.localizedDescription)")
        return "";
    }
    do {
        try jpegData.write(to: fileURL)
        return fileName;
    } catch {
        return "";
    }
}
