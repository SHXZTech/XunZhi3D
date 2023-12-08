//
//  CaptureModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/15.
//


import Foundation
import MapKit
import os

enum CloudButtonState {
    case upload, uploading, processing, download, downloading, downloaded
}

struct RTKdata{
    var longitude: Double
    var latitude: Double
    var horizontalAccuracy: Double
    var verticalAccuracy: Double
    var fixStatus: Int
    var height: Double
    var timeStamp: Date
    var GpsLocations: CLLocationCoordinate2D
}

struct CaptureModel: Identifiable {
    var id:UUID                         //UUID
    var isExist:Bool = false            // is folder exist
    var isRawMeshExist:Bool = false     // is rawmesh enable
    var isDepth:Bool = false            // is depth enable
    var isPose:Bool = false             // is pose enable
    var isGPS:Bool = false              //is gps enable
    var isRTK:Bool = false              //is rtk enable
    var frameCount:Int = 0              //image frame count
    var rawMeshURL: URL?                //raw mesh url
    var objModelURL: URL?               //obj file url
    var scanFolder: URL?                //scan folder url
    var totalSize: Int64?               //total size of folder in ""
    var cloudStatus:CloudButtonState?   // is updated to cloud
    var createDate: Date?               //creation date
    var createLocation: String?         //creation location
    var createLat: String?
    var createLon: String?
    var minHorizontalAccuracy: Float?
    var minVerticalAccuracy: Float?
    var averateHeigh: Float?
    var gpsCoordinate: String = "WGS84"
    var rtkDataArray : [RTKdata] = []
}

