//
//  GeoToolBox.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2024/6/7.
//


import Foundation
import simd

func quaternionToRotationMatrix(_ q: [Double]) -> simd_double3x3 {
    let x = q[0], y = q[1], z = q[2], w = q[3]
    let xx = x * x, yy = y * y, zz = z * z
    let xy = x * y, xz = x * z, yz = y * z
    let wx = w * x, wy = w * y, wz = w * z
    
    return simd_double3x3(rows: [
        simd_double3(1.0 - 2.0 * (yy + zz), 2.0 * (xy - wz), 2.0 * (xz + wy)),
        simd_double3(2.0 * (xy + wz), 1.0 - 2.0 * (xx + zz), 2.0 * (yz - wx)),
        simd_double3(2.0 * (xz - wy), 2.0 * (yz + wx), 1.0 - 2.0 * (xx + yy))
    ])
}


func cartesian_to_wgs84(origin: [Double], localPoint: simd_double3, quaternion: [Double], translation: [Double]) -> Geodetic {
    // Convert quaternion to rotation matrix
    let rotationMatrix = quaternionToRotationMatrix(quaternion)
    
    // Apply translation and rotation
    let translatedPoint = localPoint + simd_double3(translation)
    let rotatedPoint = rotationMatrix * translatedPoint
    
    // Convert Cartesian to WGS84
    let wgs84Position = fromCartesian(reference: origin, cartesian: [rotatedPoint.x, rotatedPoint.y])
    
    // Height adjustment (z-axis in Cartesian)
    let height = rotatedPoint.z + translation[2]
    
    return Geodetic(latitude: wgs84Position[0], longitude: wgs84Position[1], height: height)
}







struct Geodetic {
    var latitude: Double
    var longitude: Double
    var height: Double
}

struct Cartesian {
    var x: Double
    var y: Double
    var z: Double
}

let M_PI = Double.pi
let DEG_TO_RAD = M_PI / 180.0
let HALF_PI = M_PI / 2.0
let EPSILON10 = 1.0e-10
let EPSILON12 = 1.0e-12
let EQUATOR_RADIUS = 6378137.0
let FLATTENING = 1.0 / 298.257223563
let SQUARED_ECCENTRICITY = 2.0 * FLATTENING - FLATTENING * FLATTENING

let C00 = 1.0
let C02 = 0.25
let C04 = 0.046875
let C06 = 0.01953125
let C08 = 0.01068115234375
let C22 = 0.75
let C44 = 0.46875
let C46 = 0.01302083333333333333
let C48 = 0.00712076822916666666
let C66 = 0.36458333333333333333
let C68 = 0.00569661458333333333
let C88 = 0.3076171875

let R0 = C00 - SQUARED_ECCENTRICITY * (C02 + SQUARED_ECCENTRICITY * (C04 + SQUARED_ECCENTRICITY * (C06 + SQUARED_ECCENTRICITY * C08)))
let R1 = SQUARED_ECCENTRICITY * (C22 - SQUARED_ECCENTRICITY * (C04 + SQUARED_ECCENTRICITY * (C06 + SQUARED_ECCENTRICITY * C08)))
let R2T = SQUARED_ECCENTRICITY * SQUARED_ECCENTRICITY
let R2 = R2T * (C44 - SQUARED_ECCENTRICITY * (C46 + SQUARED_ECCENTRICITY * C48))
let R3T = R2T * SQUARED_ECCENTRICITY
let R3 = R3T * (C66 - SQUARED_ECCENTRICITY * C68)
let R4 = R3T * SQUARED_ECCENTRICITY * C88

func mlfn(_ lat: Double) -> Double {
    let sin_phi = sin(lat)
    let cos_phi = cos(lat) * sin_phi
    let squared_sin_phi = sin_phi * sin_phi
    return (R0 * lat - cos_phi * (R1 + squared_sin_phi * (R2 + squared_sin_phi * (R3 + squared_sin_phi * R4))))
}

func toCartesian(reference: [Double], position: [Double]) -> [Double] {
    let ML0 = mlfn(reference[0] * DEG_TO_RAD)

    func msfn(sinPhi: Double, cosPhi: Double, es: Double) -> Double {
        return (cosPhi / sqrt(1.0 - es * sinPhi * sinPhi))
    }

    func project(lat: Double, lon: Double) -> [Double] {
        var retVal = [lon, -1.0 * ML0]
        if !(abs(lat) < EPSILON10) {
            let ms = (abs(sin(lat)) > EPSILON10) ? msfn(sinPhi: sin(lat), cosPhi: cos(lat), es: SQUARED_ECCENTRICITY) / sin(lat) : 0.0
            retVal[0] = ms * sin(lon * sin(lat))
            retVal[1] = (mlfn(lat) - ML0) + ms * (1.0 - cos(lon * sin(lat)))
        }
        return retVal
    }

    func fwd(lat: Double, lon: Double) -> [Double] {
            var mutableLat = lat
            var mutableLon = lon
            let D = abs(mutableLat) - HALF_PI
            if (D > EPSILON12) || (abs(mutableLon) > 10.0) {
                return [0.0, 0.0]
            }
            if abs(D) < EPSILON12 {
                mutableLat = (mutableLat < 0.0) ? -1.0 * HALF_PI : HALF_PI
            }
            mutableLon -= reference[1] * DEG_TO_RAD
            let projectedRetVal = project(lat: mutableLat, lon: mutableLon)
            return [EQUATOR_RADIUS * projectedRetVal[0], EQUATOR_RADIUS * projectedRetVal[1]]
        }

    return fwd(lat: position[0] * DEG_TO_RAD, lon: position[1] * DEG_TO_RAD)
}

func fromCartesian(reference: [Double], cartesian: [Double]) -> [Double] {
    let EPSILON10 = 1.0e-4
    let signLon = (cartesian[0] < 0) ? -1 : 1
    let signLat = (cartesian[1] < 0) ? -1 : 1

    var approximateWGS84Position = reference
    var cartesianResult = toCartesian(reference: reference, position: approximateWGS84Position)

    var dPrev = Double.greatestFiniteMagnitude
    var d = abs(cartesian[1] - cartesianResult[1])
    var incLat = 1e-6
    while (d < dPrev) && (d > EPSILON10) {
        incLat = max(1e-6 * d, 1e-9)
        approximateWGS84Position[0] += Double(signLat) * incLat
        cartesianResult = toCartesian(reference: reference, position: approximateWGS84Position)
        dPrev = d
        d = abs(cartesian[1] - cartesianResult[1])
    }

    dPrev = Double.greatestFiniteMagnitude
    d = abs(cartesian[0] - cartesianResult[0])
    var incLon = 1e-6
    while (d < dPrev) && (d > EPSILON10) {
        incLon = max(1e-6 * d, 1e-9)
        approximateWGS84Position[1] += Double(signLon) * incLon
        cartesianResult = toCartesian(reference: reference, position: approximateWGS84Position)
        dPrev = d
        d = abs(cartesian[0] - cartesianResult[0])
    }

    return approximateWGS84Position
}
