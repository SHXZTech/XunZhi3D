import SwiftUI
import MapKit

struct MapWithMarkView: View {
    var gpsArray: [RTKdata]

    @State private var region: MKCoordinateRegion

    private var firstMarker: [MapMarker] {
        if let firstLocation = gpsArray.first {
            let transformedCoordinate = CoordinateService.wgs84ToGcj02(lat: firstLocation.latitude, lng: firstLocation.longitude)
            return [MapMarker(coordinate: transformedCoordinate)]
        }
        return []
    }

    init(gpsArray: [RTKdata]) {
        self.gpsArray = gpsArray

        if let firstLocation = gpsArray.first {
            let firstTransformedLocation = CoordinateService.wgs84ToGcj02(lat: firstLocation.latitude, lng: firstLocation.longitude)
            self._region = State(initialValue: MKCoordinateRegion(
                center: firstTransformedLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001) // Smaller delta for closer zoom
            ))
        } else {
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))
        }
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: firstMarker) { marker in
            MapAnnotation(coordinate: marker.coordinate) {
                Image(systemName: "mappin.and.ellipse")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .cornerRadius(15)
    }
}

struct MapMarker: Identifiable {
    let id: Int
    let coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D) {
        // Using hash of coordinates as a stable identifier
        self.id = coordinate.latitude.hashValue ^ coordinate.longitude.hashValue
        self.coordinate = coordinate
    }
}

