import SwiftUI
import MapKit

struct MapWithMarkView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 31.293350295, longitude: 121.381339780),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    
    let markers = [
        Marker(location: CLLocationCoordinate2D(latitude: 31.293350295, longitude: 121.381339780))
        // Add more markers as needed
    ]

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: markers) { marker in
            // Use MapAnnotation to provide a custom view with a system image
            MapAnnotation(coordinate: marker.location) {
                Image(systemName: "mappin.and.ellipse")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20) // Adjust the size as needed
                    .foregroundColor(.green) // You can change the color as needed
            }
        }
        .edgesIgnoringSafeArea(.all)
        .cornerRadius(15)
    }
}

struct Marker: Identifiable {
    let id = UUID()
    let location: CLLocationCoordinate2D
}

struct MapWithMarkView_Previews: PreviewProvider {
    static var previews: some View {
        MapWithMarkView()
    }
}

