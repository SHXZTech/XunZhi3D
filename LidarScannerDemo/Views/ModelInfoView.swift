//
//  ModelInfoView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/17.
//
import SwiftUI

struct ModelInfoView: View {
    
    // Assuming you have a CaptureViewService that provides these details
    // @Binding var captureService: CaptureViewService
    
    // Temporary mock data for preview purposes
    let date = "11月16日 10:14"
    let coordinateSystem = "WGS 84 + 大地高"
    let totalPoints = "85"
    let pointsCaptured = "85/85 (100%)"
    let range = "100,000 m"
    let fileSize = "517.94 MB"
    
    @State private var selectedSegment = 0
    
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
                MapWithMarkView()
                Spacer()
            }
            .padding(.horizontal, 10)
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
                Text("近民生路1399号")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
        }
        .padding(.vertical,5)
    }
    
    private var ImageCountAndSize: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text("图片数量")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text("50")
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
                Text("560MB")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
        }
        .padding(.vertical,5)
    }
    
    private var RtkAndGpsStatus: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text("RTK")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text("开启")
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
                Text("开启")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
        }
        .padding(.vertical,5)
    }
    
    private var LatitudeAndLongitude: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text("经度")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text("121.030203434")
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
                Text("31.34353456543")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
        }
        .padding(.vertical,5)
    }
    
    private var HorizontalAndVerticalAccuracy: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text("水平精度")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text("0.001米")
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
                Text("0.0013米")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
        }
        .padding(.vertical,5)
    }
    
    private var HeightAndCoordinator: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text("高程")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal,10)
                Text("10.69米")
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
                Text("WGS84，黄海高程")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
            }
            .frame(width: 200,alignment: .leading)
        }
        .padding(.vertical,5)
    }
    
}



// Preview Provider
struct ModelInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ModelInfoView()
    }
}
