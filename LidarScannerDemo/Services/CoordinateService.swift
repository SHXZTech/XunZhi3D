//
//  CoordinateService.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/18.
//

import Foundation
import CoreLocation
import CoreLocation


struct CoordinateService {

    static let pi = Double.pi
    static let a = 6378245.0
    static let ee = 0.00669342162296594323

    static func transformLat(lng: Double, lat: Double) -> Double {
        var ret = -100.0 + 2.0 * lng + 3.0 * lat + 0.2 * lat * lat + 0.1 * lng * lat + 0.2 * sqrt(fabs(lng))
        ret += (20.0 * sin(6.0 * lng * pi) + 20.0 * sin(2.0 * lng * pi)) * 2.0 / 3.0
        ret += (20.0 * sin(lat * pi) + 40.0 * sin(lat / 3.0 * pi)) * 2.0 / 3.0
        ret += (160.0 * sin(lat / 12.0 * pi) + 320 * sin(lat * pi / 30.0)) * 2.0 / 3.0
        return ret
    }

    static func transformLng(lng: Double, lat: Double) -> Double {
        var ret = 300.0 + lng + 2.0 * lat + 0.1 * lng * lng + 0.1 * lng * lat + 0.1 * sqrt(fabs(lng))
        ret += (20.0 * sin(6.0 * lng * pi) + 20.0 * sin(2.0 * lng * pi)) * 2.0 / 3.0
        ret += (20.0 * sin(lng * pi) + 40.0 * sin(lng / 3.0 * pi)) * 2.0 / 3.0
        ret += (150.0 * sin(lng / 12.0 * pi) + 300.0 * sin(lng / 30.0 * pi)) * 2.0 / 3.0
        return ret
    }

    static func wgs84ToGcj02(lat: Double, lng: Double) -> CLLocationCoordinate2D {
        let dLat = transformLat(lng: lng - 105.0, lat: lat - 35.0)
        let dLng = transformLng(lng: lng - 105.0, lat: lat - 35.0)
        let radLat = lat / 180.0 * pi
        var magic = sin(radLat)
        magic = 1 - ee * magic * magic
        let sqrtMagic = sqrt(magic)
        let mgLat = lat + (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi)
        let mgLng = lng + (dLng * 180.0) / (a / sqrtMagic * cos(radLat) * pi)
        return CLLocationCoordinate2D(latitude: mgLat, longitude: mgLng)
    }

    static func gcj02ToWgs84(lat: Double, lng: Double) -> CLLocationCoordinate2D {
        let dLat = transformLat(lng: lng - 105.0, lat: lat - 35.0)
        let dLng = transformLng(lng: lng - 105.0, lat: lat - 35.0)
        let radLat = lat / 180.0 * pi
        var magic = sin(radLat)
        magic = 1 - ee * magic * magic
        let sqrtMagic = sqrt(magic)
        let mgLat = lat + (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi)
        let mgLng = lng + (dLng * 180.0) / (a / sqrtMagic * cos(radLat) * pi)
        return CLLocationCoordinate2D(latitude: lat * 2 - mgLat, longitude: lng * 2 - mgLng)
    }
    
    static func fetchLocation(forLatitude latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error)")
                completion(nil)
                return
            }
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? ""
                let district = placemark.subLocality ?? ""
                let road = placemark.thoroughfare ?? ""
                let number = placemark.subThoroughfare ?? ""
                let shortAddress = "\(city) \(district) \(road) \(number)".trimmingCharacters(in: .whitespaces)
                completion(shortAddress)
            } else {
                completion("Unknown Location")
            }
        }
    }

}



