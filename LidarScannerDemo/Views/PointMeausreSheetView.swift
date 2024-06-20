//
//  PointMeausreSheetView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 1824/6/7.
//



import SwiftUI
import simd


struct PointMeasureSheetView: View {
    @Binding var isPresented: Bool
    @Binding var point_x: Double
    @Binding var point_y: Double
    @Binding var point_z: Double
    var uuid: UUID
    var is_geo_json_exist: Bool
    var quaternion:[Double]
    var translation: [Double]
    var origin:[Double]
    
    init(isPresented: Binding<Bool>, point_x: Binding<Double>, point_y: Binding<Double>, point_z: Binding<Double>, uuid: UUID) {
        self._isPresented = isPresented
        self._point_x = point_x
        self._point_y = point_y
        self._point_z = point_z
        self.uuid = uuid
        self.is_geo_json_exist = isGeoJsonExist(uuid: uuid)
        self.quaternion = loadGeoJsonQuaternion(uuid: uuid)
        self.translation = loadGeoJsonTranslation(uuid: uuid)
        self.origin = loadGeoJsonOrigin(uuid: uuid)
    }
//    let quaternion: [Double] = [-0.010326089637590382, -0.023810496269798725, 0.1286007365190827, 0.9913567888035729]
//    let translation: [Double] = [0.026775233714395164, -0.02193400445618508, 5.791241740067435]
//    let origin: [Double] = [31.227069052, 121.545507977]
//   
    
    
   
    
    var body: some View {
        VStack {
            ZStack{
                HStack{
                    Spacer()
                    Text(NSLocalizedString("Point", comment: ""))
                        .font(.title2)
                    Spacer()
                }
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title2)
                            .padding()
                    }
                    .padding(.horizontal, 10)
                    Spacer()
                }
            }
            Spacer()
            if abs(point_x) > 0.00001 {
                HStack {
                        VStack(alignment: .leading) {
                            Text("\(NSLocalizedString("X(m): ", comment: "")) \(String(format: "%.2f", point_x))")
                                .foregroundColor(.cyan)
                                .font(.system(size: 18))
                            Text("\(NSLocalizedString("Y(m): ", comment: "")) \(String(format: "%.2f", -point_z))")
                                .foregroundColor(.cyan)
                                .font(.system(size: 18))
                            Text("\(NSLocalizedString("Z(m): ", comment: "")) \(String(format: "%.2f", point_y))")
                                .foregroundColor(.cyan)
                                .font(.system(size: 18))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        VStack(alignment: .leading) {
                            let globalCoordinates = cartesian_to_wgs84(
                                origin: origin,
                                localPoint: simd_double3(point_x, -point_z, point_y),
                                quaternion: quaternion,
                                translation: translation
                            )
                            Text("\(NSLocalizedString("经度(N): ", comment: "")) \(String(format: "%.7f", globalCoordinates.latitude))° ")
                                .foregroundColor(.cyan)
                                .font(.system(size: 18))
                            Text("\(NSLocalizedString("纬度(W): ", comment: "")) \(String(format: "%.6f", globalCoordinates.longitude))° ")
                                .foregroundColor(.cyan)
                                .font(.system(size: 18))
                            Text("\(NSLocalizedString("高程(m): ", comment: "")) \(String(format: "%.2f", globalCoordinates.height))")
                                .foregroundColor(.cyan)
                                .font(.system(size: 18))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                }
            } else {
                Text(NSLocalizedString("tap model to measure", comment: ""))
            }
            Spacer()
        }
    }
}


func isGeoJsonExist(uuid: UUID)->Bool{
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let geo_json_name = "geo.json"
    let texturedMeshPath = documentsDirectory.appendingPathComponent("\(uuid.uuidString)/textured/\(geo_json_name)").path
    let is_geo_json_exist = fileManager.fileExists(atPath: texturedMeshPath)
    print("Debug: is_geo_json_exist = ",is_geo_json_exist)
    return is_geo_json_exist
}

//TODO: Modify these functions into a service
func loadGeoJsonQuaternion(uuid: UUID) -> [Double] {
    guard let geoJson = loadGeoJson(uuid: uuid) else {
        return []
    }
    return geoJson["quaternion"] as? [Double] ?? []
}

func loadGeoJsonTranslation(uuid: UUID) -> [Double] {
    guard let geoJson = loadGeoJson(uuid: uuid) else {
        return []
    }
    return geoJson["translation"] as? [Double] ?? []
}

func loadGeoJsonOrigin(uuid: UUID) -> [Double] {
    guard let geoJson = loadGeoJson(uuid: uuid) else {
        return []
    }
    return geoJson["origin"] as? [Double] ?? []
}

func loadGeoJson(uuid: UUID) -> [String: Any]? {
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let geoJsonName = "geo.json"
    let geoJsonPath = documentsDirectory.appendingPathComponent("\(uuid.uuidString)/textured/\(geoJsonName)").path
    
    guard fileManager.fileExists(atPath: geoJsonPath),
          let geoJsonData = try? Data(contentsOf: URL(fileURLWithPath: geoJsonPath)),
          let geoJson = try? JSONSerialization.jsonObject(with: geoJsonData, options: []) as? [String: Any] else {
        return nil
    }
    print("loaded geojson = ", geoJson)
    return geoJson
}
