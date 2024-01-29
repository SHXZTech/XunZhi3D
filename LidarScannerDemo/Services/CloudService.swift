import Foundation
import MobileCoreServices


class CloudServiceSessionDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    var progressHandler: ((Float) -> Void)?
    var completionHandler: ((Result<UploadRouteResponse, Error>) -> Void)?
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        DispatchQueue.main.async {
            self.progressHandler?(progress)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.completionHandler?(.failure(error))
            }
            return
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        do {
            let responseObj = try JSONDecoder().decode(UploadRouteResponse.self, from: data)
            DispatchQueue.main.async {
                self.completionHandler?(.success(responseObj))
            }
        } catch {
            DispatchQueue.main.async {
                self.completionHandler?(.failure(error))
            }
        }
    }
}

struct CloudService  {
    var progressObservation: NSKeyValueObservation?
    let serverConfig: ServerConfigModel
    private let sessionDelegate = CloudServiceSessionDelegate()
    init() {
        let loadedConfig = ServerConfigModel.loadFromPlist(named: "ServerConfig")
        self.serverConfig = loadedConfig!
    }
    
    // Function to create a capture
    func createCapture(uuid: UUID, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = serverConfig.captureCreateURL else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["uuid": uuid.uuidString]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    completion(.success(responseString))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
}

extension CloudService {
    mutating func downloadTexture(uuid: UUID, to destinationURL: URL, progress: @escaping (Float) -> Void, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = serverConfig.getDownloadTextureURL else {
            completion(.failure(CloudServiceError.invalidURL))
            return
        }
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [URLQueryItem(name: "uuid", value: uuid.uuidString)]
        guard let queryURL = urlComponents?.url else {
            completion(.failure(CloudServiceError.invalidURL))
            return
        }
        var request = URLRequest(url: queryURL)
        request.httpMethod = "GET"
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let task = session.downloadTask(with: request) { localURL, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(CloudServiceError.unknown))
                return
            }
            guard let tempLocalURL = localURL else {
                completion(.failure(CloudServiceError.unknown))
                return
            }
            do {
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.moveItem(at: tempLocalURL, to: destinationURL)
                completion(.success(destinationURL))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
        
        self.progressObservation = task.progress.observe(\.fractionCompleted) { progressObj, _ in
                    DispatchQueue.main.async {
                        let progressValue = Float(progressObj.fractionCompleted)
                        progress(progressValue)
                    }
                }
    }
}

extension CloudService {
    
    func uploadCapture(uuid: UUID, fileURL: URL, progressHandler: @escaping (Float) -> Void, completion: @escaping (Result<UploadRouteResponse, Error>) -> Void) {
        guard let url = serverConfig.uploadCaptureURL else {
            completion(.failure(CloudServiceError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append(convertFormField(named: "uuid", value: uuid.uuidString, using: boundary))
        
        do {
            let fileData = try Data(contentsOf: fileURL)
            let filename = fileURL.lastPathComponent
            let mimeType = mimeTypeForPath(path: fileURL.path)
            body.append(convertFileData(fieldName: "file", fileName: filename, mimeType: mimeType, fileData: fileData, using: boundary))
        } catch {
            completion(.failure(error))
            return
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        sessionDelegate.progressHandler = progressHandler
        sessionDelegate.completionHandler = completion
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: OperationQueue.main)
        
        let task = session.uploadTask(with: request, from: body)
        task.resume()
    }
    
    // Helper methods for multipart/form-data
    private func convertFormField(named name: String, value: String, using boundary: String) -> Data {
        let data = NSMutableData()
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        data.appendString("\(value)\r\n")
        return data as Data
    }
    
    private func convertFileData(fieldName: String,
                                 fileName: String,
                                 mimeType: String,
                                 fileData: Data,
                                 using boundary: String) -> Data {
        let data = NSMutableData()
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        return data as Data
    }
    
    private func mimeTypeForPath(path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue() {
            if let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimeType as String
            }
        }
        return "application/octet-stream"
    }
}

extension CloudService {
    func getCaptureStatus(uuid: UUID, completion: @escaping (Result<CaptureStatusResponse, Error>) -> Void) {
        guard let url = serverConfig.getCaptureStatusURL else {
            completion(.failure(CloudServiceError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Assuming the UUID is sent as a query parameter
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [URLQueryItem(name: "uuid", value: uuid.uuidString)]
        
        guard let queryURL = urlComponents?.url else {
            completion(.failure(CloudServiceError.invalidURL))
            return
        }
        request.url = queryURL
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(CloudServiceError.unknown))
                return
            }
            do {
                let responseObj = try JSONDecoder().decode(CaptureStatusResponse.self, from: data)
                completion(.success(responseObj))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}



struct CaptureStatusResponse: Codable {
    var message: String
    var status: Int
    // Add other fields based on your server's response
}



enum CloudServiceError: Error {
    case invalidURL
    case unknown
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: .utf8, allowLossyConversion: false)
        append(data!)
    }
}

struct UploadRouteResponse: Codable {
    var message: String
    // Add other fields based on your server's response
    // If the server includes a success flag, add it here as an optional property
    var success: Bool?
    
    // Include any additional fields that your server may return
    // Make them optional if they are not always present in the response
    // var additionalField: DataType?
}




extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

