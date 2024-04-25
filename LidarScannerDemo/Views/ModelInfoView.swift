//
//  ModelInfoView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/17.
//
import SwiftUI

struct ModelInfoView: View {
    var captureModel: CaptureModel
    var date: String = "-"
    var frameCount: String = "-"
    var folderSize: String = "-"
    var rtkEnable: String = "-"
    var gpsEnable: String = "-"
    var initLat: String = "-"
    var initLon: String = "-"
    var initHeight: String = "-"
    var coordinateSystem: String = "-"
    var horizontalAccuracy: String = "-"
    var verticalAccuracy: String = "-"
    let half_scrren_width = UIScreen.main.bounds.width / 2 - 10
    
    @State private var location: String
    
    init(capturemodel_: CaptureModel) {
        self.captureModel = capturemodel_
        _location = State(initialValue: captureModel.createLocation ?? NSLocalizedString("Unknown location",comment: ""))
        
        // Convert createDate to a displayable format
        if let createDate = captureModel.createDate {
            let formatter = DateFormatter()
            formatter.dateFormat = NSLocalizedString("date_format", comment: "")
            self.date = formatter.string(from: createDate)
        }
        // Frame Count
        self.frameCount = String(captureModel.frameCount)
        // Folder Size
        if let totalSize = captureModel.totalSize {
            self.folderSize = String(format: "%.2f MB", Double(totalSize) / 1_000_000.0)
        }
        // RTK and GPS Enable
        self.rtkEnable = captureModel.isRTK ? NSLocalizedString("open", comment: "") : NSLocalizedString("关闭", comment: "")
        self.gpsEnable = captureModel.isGPS ? NSLocalizedString("open", comment: "") : NSLocalizedString("关闭", comment: "")
        // Initial Latitude, Longitude, and Height
        if let firstRtkData = captureModel.rtkDataArray.first {
            self.initLat = String(firstRtkData.latitude)
            self.initLon = String(firstRtkData.longitude)
            self.initHeight = String(format: NSLocalizedString("height_format", comment: ""), firstRtkData.height)
        }
        // Coordinate System
        self.coordinateSystem = captureModel.gpsCoordinate
        // Horizontal and Vertical Accuracy
        let minHorizontal = captureModel.rtkDataArray.min(by: { $0.horizontalAccuracy < $1.horizontalAccuracy })?.horizontalAccuracy
        let minVertical = captureModel.rtkDataArray.min(by: { $0.verticalAccuracy < $1.verticalAccuracy })?.verticalAccuracy
        
        if let minHAcc = minHorizontal {
            self.horizontalAccuracy = String(format: NSLocalizedString("height_format", comment: ""), minHAcc)
        }
        if let minVAcc = minVertical {
            self.verticalAccuracy = String(format: NSLocalizedString("height_format", comment: ""), minVAcc)
        }
    }
    
    private func fetchLocationIfNeeded() {
        if captureModel.createLocation == nil || captureModel.createLocation == NSLocalizedString("unknown location", comment: "") {
            if let firstRtkData = captureModel.rtkDataArray.first {
                let convertedCoordinates = CoordinateService.wgs84ToGcj02(lat: firstRtkData.latitude, lng: firstRtkData.longitude)
                
                CoordinateService.fetchLocation(forLatitude: convertedCoordinates.latitude, longitude: convertedCoordinates.longitude) { fetchedLocation in
                    DispatchQueue.main.async {
                        self.location = fetchedLocation ?? NSLocalizedString("unknown location", comment: "")
                    }
                }
            }
        }
    }
    
    
    
    private mutating func PreProcessCaptureModel() {
        // Convert createDate to a displayable format
        if let createDate = captureModel.createDate {
            let formatter = DateFormatter()
            formatter.dateFormat = NSLocalizedString("date_format", comment: "") // Adjust the date format as needed
            self.date = formatter.string(from: createDate)
        }
        
        // Frame Count
        self.frameCount = String(captureModel.frameCount)
        
        // Folder Size
        if let totalSize = captureModel.totalSize {
            self.folderSize = String(format: "%.2f MB", Double(totalSize) / 1_000_000.0)
        }
        
        // RTK and GPS Enable
        self.rtkEnable = captureModel.isRTK ? NSLocalizedString("open", comment: "") : NSLocalizedString("关闭", comment: "")
        self.gpsEnable = captureModel.isGPS ? NSLocalizedString("open", comment: "") : NSLocalizedString("关闭", comment: "")
        
        // Initial Latitude, Longitude, and Height
        self.initLat = captureModel.createLat ?? "-"
        self.initLon = captureModel.createLon ?? "-"
        self.initHeight = captureModel.createHeight ?? "-"
        
        if let firstRtkData = captureModel.rtkDataArray.first {
            self.initLat = String(firstRtkData.latitude)
            self.initLon = String(firstRtkData.longitude)
            self.initHeight = String(format: NSLocalizedString("height_format", comment: ""), firstRtkData.height)
        }
        
        // Coordinate System
        self.coordinateSystem = captureModel.gpsCoordinate
        
        // Horizontal and Vertical Accuracy
        if let hAccuracy = captureModel.minHorizontalAccuracy {
            self.horizontalAccuracy = String(format: NSLocalizedString("height_format", comment: ""), hAccuracy)
        }
        if let vAccuracy = captureModel.minVerticalAccuracy {
            self.verticalAccuracy = String(format: NSLocalizedString("height_format", comment: ""), vAccuracy)
        }
        
    }
    
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading){
                Spacer().frame(height: 60)
                createDateAndLocation
                ImageCountAndSize
                RtkAndGpsStatus
                LatitudeAndLongitude
                HeightAndCoordinator
                HorizontalAndVerticalAccuracy
                MapWithMarkView(gpsArray: captureModel.rtkDataArray)
                Spacer()
            }
            .padding(.horizontal, 20)
            .onAppear(perform: fetchLocationIfNeeded)
        }
    }
    
    private var createDateAndLocation: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text(NSLocalizedString("create_format", comment: ""))
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(date)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: half_scrren_width,alignment: .leading)
            VStack(alignment: .leading){
                Text(NSLocalizedString("create_location", comment: ""))
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(location)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: half_scrren_width,alignment: .leading)
        }
        .padding(.vertical,2)
    }
    
    private var ImageCountAndSize: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text(NSLocalizedString("image_count", comment: ""))
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(frameCount)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: half_scrren_width,alignment: .leading)
            VStack(alignment: .leading){
                Text(NSLocalizedString("folder_size", comment: ""))
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(folderSize)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: half_scrren_width,alignment: .leading)
        }
        .padding(.vertical,2)
    }
    
    private var RtkAndGpsStatus: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text("RTK")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(rtkEnable)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: half_scrren_width,alignment: .leading)
            VStack(alignment: .leading){
                Text("GPS")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(gpsEnable)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: half_scrren_width,alignment: .leading)
        }
        .padding(.vertical,2)
    }
    
    private var LatitudeAndLongitude: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text(NSLocalizedString("Latitude", comment: ""))
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(initLat)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: half_scrren_width,alignment: .leading)
            VStack(alignment: .leading){
                Text(NSLocalizedString("Longitute", comment: ""))
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(initLon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: half_scrren_width,alignment: .leading)
        }
        .padding(.vertical,2)
    }
    
    private var HorizontalAndVerticalAccuracy: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text(NSLocalizedString("horizontal_accuracy", comment: ""))
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(horizontalAccuracy)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: half_scrren_width,alignment: .leading)
            VStack(alignment: .leading){
                Text(NSLocalizedString("Vertical_accuracy", comment: ""))
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(verticalAccuracy)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: half_scrren_width,alignment: .leading)
        }
        .padding(.vertical,2)
    }
    
    private var HeightAndCoordinator: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text(NSLocalizedString("height", comment: ""))
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(initHeight)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: half_scrren_width,alignment: .leading)
            VStack(alignment: .leading){
                Text(NSLocalizedString("Coordinate", comment: ""))
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(coordinateSystem)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: half_scrren_width,alignment: .leading)
        }
        .padding(.vertical,2)
    }
    
}

struct ModelInfoView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello world")
    }
}
