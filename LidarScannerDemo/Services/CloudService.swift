import Foundation
import MobileCoreServices


struct CloudService {
    let serverConfig: ServerConfigModel

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
    func downloadTexture(uuid: UUID, to destinationURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
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

        let task = URLSession.shared.downloadTask(with: request) { localURL, response, error in
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

            // Use the provided destination URL to save the file
            let permanentURL = destinationURL
            do {
                // Move the file from the temporary location to the permanent location
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: permanentURL.path) {
                    try fileManager.removeItem(at: permanentURL)
                }
                try fileManager.moveItem(at: tempLocalURL, to: permanentURL)
                completion(.success(permanentURL))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

extension CloudService {
    
    func uploadCapture(uuid: UUID, fileURL: URL, completion: @escaping (Result<UploadRouteResponse, Error>) -> Void) {
        guard let url = serverConfig.uploadCaptureURL else {
            completion(.failure(CloudServiceError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add the UUID part
        body.append(convertFormField(named: "uuid", value: uuid.uuidString, using: boundary))

        // Add the file part
        do {
            let fileData = try Data(contentsOf: fileURL)
            let filename = fileURL.lastPathComponent
            let mimeType = mimeTypeForPath(path: fileURL.path)
            body.append(convertFileData(fieldName: "file",
                                        fileName: filename,
                                        mimeType: mimeType,
                                        fileData: fileData,
                                        using: boundary))
        } catch {
            completion(.failure(error))
            return
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                completion(.failure(CloudServiceError.unknown))
                return
            }
            // Decode your response into `UploadRouteResponse` if you have a defined structure
            do {
                let responseObj = try JSONDecoder().decode(UploadRouteResponse.self, from: data)
                completion(.success(responseObj))
            } catch {
                completion(.failure(error))
            }
        }.resume()
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

