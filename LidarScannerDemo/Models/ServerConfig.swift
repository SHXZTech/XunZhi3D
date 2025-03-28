//
//  ServerConfig.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/12/21.
//

import Foundation

struct ServerConfigModel {
    var serverAddress: String
    var serverPort: Int
    var captureCreateEndpoint: String
    var getUploadRouteEndpoint: String
    var uploadCaptureEndpoint: String
    var getCaptureStatusEndpoint: String
    var downloadTextureEndpoint: String
    var registerUserEndpoint: String
    
    var captureCreateURL: URL? {
        URL(string: "http://\(serverAddress):\(serverPort)\(captureCreateEndpoint)")
    }
    
    var getUploadRouteURL: URL? {
        URL(string: "http://\(serverAddress):\(serverPort)\(getUploadRouteEndpoint)")
    }
    
    var uploadCaptureURL: URL?{
        URL(string: "http://\(serverAddress):\(serverPort)\(uploadCaptureEndpoint)")
    }
    
    var getCaptureStatusURL: URL?{
        URL(string: "http://\(serverAddress):\(serverPort)\(getCaptureStatusEndpoint)")
    }
    
    var getDownloadTextureURL: URL?{
        URL(string: "http://\(serverAddress):\(serverPort)\(downloadTextureEndpoint)")
    }
    
    var getRegisterUserURL: URL?{
        URL(string: "http://\(serverAddress):\(serverPort)\(registerUserEndpoint)")
    }
    
    // This initializer can be used to initialize the model with specific values.
    init(serverAddress: String, serverPort: Int, captureCreateEndpoint: String, getUploadRouteEndpoint: String, uploadCaptureEndPoint: String ,getCaptureStatusEndpoint: String,downloadTextureEndpoing: String,registerUserEndpoint: String, additionalConfig: [String: Any]) {
        self.serverAddress = serverAddress
        self.serverPort = serverPort
        self.captureCreateEndpoint = captureCreateEndpoint
        self.getUploadRouteEndpoint = getUploadRouteEndpoint
        self.uploadCaptureEndpoint = uploadCaptureEndPoint
        self.getCaptureStatusEndpoint = getCaptureStatusEndpoint
        self.downloadTextureEndpoint = downloadTextureEndpoing
        self.registerUserEndpoint = registerUserEndpoint
    }
    
    // Static method to load the server configuration from a plist file.
    static func loadFromPlist(named plistName: String) -> ServerConfigModel? {
        guard let url = Bundle.main.url(forResource: plistName, withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dictionary = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            return nil
        }
        
        guard let serverAddress = dictionary["serverAddress"] as? String,
              let serverPort = dictionary["serverPort"] as? Int,
              let captureCreateEndpoint = dictionary["captureCreateEndpoint"] as? String,
              let uploadCaptureEndpoint = dictionary["uploadCaptureEndpoint"] as? String,
              let getCaptureStatusEndpoint = dictionary["getCaptureStatusEndpoint"] as? String,
              let downloadTextureEndpoint = dictionary["downloadTextureEndpoint"] as? String,
              let registerUserEndpoint = dictionary["registerUserEndpoint"] as? String,
              let getUploadRouteEndpoint = dictionary["getUploadRouteEndpoint"] as? String else {
            return nil
        }
        return ServerConfigModel(serverAddress: serverAddress, serverPort: serverPort, captureCreateEndpoint: captureCreateEndpoint, getUploadRouteEndpoint: getUploadRouteEndpoint, uploadCaptureEndPoint: uploadCaptureEndpoint, getCaptureStatusEndpoint: getCaptureStatusEndpoint, downloadTextureEndpoing: downloadTextureEndpoint, registerUserEndpoint: registerUserEndpoint, additionalConfig: dictionary)
    }
    
}
