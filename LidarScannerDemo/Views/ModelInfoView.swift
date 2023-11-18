//
//  ModelInfoView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/17.
//
import SwiftUI

struct ModelInfoView: View {
    
    // Assuming you have a CaptureViewService that provides these details
    //@Binding var captureService: CaptureViewService
    var captureModel: CaptureModel
    // Temporary mock data for preview purposes
    var date: String = "-"
    var location: String = "-"
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
    
    
    
    
    
    // Call this function in the init
    init(capturemodel_: CaptureModel) {
        self.captureModel = capturemodel_
        // Convert createDate to a displayable format
        if let createDate = captureModel.createDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM月dd日 HH:mm" // Adjust the date format as needed
            self.date = formatter.string(from: createDate)
        }
        // Location
        self.location = captureModel.createLocation ?? "Unknown Location"
        // Frame Count
        self.frameCount = String(captureModel.frameCount)
        // Folder Size
        if let totalSize = captureModel.totalSize {
            self.folderSize = String(format: "%.2f MB", Double(totalSize) / 1_000_000.0)
        }
        // RTK and GPS Enable
        self.rtkEnable = captureModel.isRTK ? "开启" : "关闭"
        self.gpsEnable = captureModel.isGPS ? "开启" : "关闭"
        // Initial Latitude, Longitude, and Height
        if let firstRtkData = captureModel.rtkDataArray.first {
            self.initLat = String(firstRtkData.latitude)
            self.initLon = String(firstRtkData.longitude)
            self.initHeight = String(format: "%.2f 米", firstRtkData.height)
        }
        // Coordinate System
        self.coordinateSystem = captureModel.gpsCoordinate
        // Horizontal and Vertical Accuracy
        let minHorizontal = captureModel.rtkDataArray.min(by: { $0.horizontalAccuracy < $1.horizontalAccuracy })?.horizontalAccuracy
        let minVertical = captureModel.rtkDataArray.min(by: { $0.verticalAccuracy < $1.verticalAccuracy })?.verticalAccuracy
        
        if let minHAcc = minHorizontal {
            self.horizontalAccuracy = String(format: "%.3f 米", minHAcc)
        }
        if let minVAcc = minVertical {
            self.verticalAccuracy = String(format: "%.3f 米", minVAcc)
        }
    }
    
    private mutating func PreProcessCaptureModel() {
        // Convert createDate to a displayable format
        if let createDate = captureModel.createDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM月dd日 HH:mm" // Adjust the date format as needed
            self.date = formatter.string(from: createDate)
        }
        
        // Location
        self.location = captureModel.createLocation ?? "Unknown Location"
        
        // Frame Count
        self.frameCount = String(captureModel.frameCount)
        
        // Folder Size
        if let totalSize = captureModel.totalSize {
            self.folderSize = String(format: "%.2f MB", Double(totalSize) / 1_000_000.0)
        }
        
        // RTK and GPS Enable
        self.rtkEnable = captureModel.isRTK ? "开启" : "关闭"
        self.gpsEnable = captureModel.isGPS ? "开启" : "关闭"
        
        // Initial Latitude, Longitude, and Height
        if let firstRtkData = captureModel.rtkDataArray.first {
            self.initLat = String(firstRtkData.latitude)
            self.initLon = String(firstRtkData.longitude)
            self.initHeight = String(format: "%.2f 米", firstRtkData.height)
        }
        
        // Coordinate System
        self.coordinateSystem = captureModel.gpsCoordinate
        
        // Horizontal and Vertical Accuracy
        if let hAccuracy = captureModel.minHorizontalAccuracy {
            self.horizontalAccuracy = String(format: "%.3f 米", hAccuracy)
        }
        if let vAccuracy = captureModel.minVerticalAccuracy {
            self.verticalAccuracy = String(format: "%.3f 米", vAccuracy)
        }
    }
    
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading){
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
        }
    }
    
    private var createDateAndLocation: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text("创建时间")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(date)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
            VStack(alignment: .leading){
                Text("创建地点")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(location)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
        }
        .padding(.vertical,2)
    }
    
    private var ImageCountAndSize: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text("图片数量")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(frameCount)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
            VStack(alignment: .leading){
                Text("文件大小")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(folderSize)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
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
            .frame(width: 200,alignment: .leading)
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
            .frame(width: 200,alignment: .leading)
        }
        .padding(.vertical,2)
    }
    
    private var LatitudeAndLongitude: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text("经度")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(initLat)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
            VStack(alignment: .leading){
                Text("纬度")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(initLon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
        }
        .padding(.vertical,2)
    }
    
    private var HorizontalAndVerticalAccuracy: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text("水平精度")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(horizontalAccuracy)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
            VStack(alignment: .leading){
                Text("垂直精度")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(verticalAccuracy)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
        }
        .padding(.vertical,2)
    }
    
    private var HeightAndCoordinator: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text("高程")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(initHeight)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
            VStack(alignment: .leading){
                Text("坐标系")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text(coordinateSystem)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
        }
        .padding(.vertical,2)
    }
    
}



// Preview Provider
struct ModelInfoView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello world")
        //ModelInfoView()
    }
}
