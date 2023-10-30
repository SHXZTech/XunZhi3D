//
//  GeoSensorView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/18.
//

import SwiftUI

struct GeoSensorView: View {
    @StateObject var rtkViewModel = RTKViewModel()
    @State private var isShowingRtkSettingPage = false // State to control the presentation of the sheet

    var body: some View {
        VStack(alignment: .leading) {
            if rtkViewModel.selectedDevice == nil {
                noRtkConnected()
            }
            else{
                rtkConnected()
            }
            Spacer()
        }
    }

    func noRtkConnected() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "location.slash.fill")
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
                    .padding(.leading, 10) // Add padding to the left of the location icon
                Spacer()
                Text("RTK")
                    .frame(maxWidth: .infinity, alignment: .center) // Center the text in the available space
                Spacer()
                Button(action: {
                    isShowingRtkSettingPage.toggle()
                }) {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                }
                .sheet(isPresented: $isShowingRtkSettingPage) {
                                    RtkSettingView(viewModel: rtkViewModel,isPresented: $isShowingRtkSettingPage)
                                }
                .padding(.trailing, 10) // Add padding to the right of the ellipsis button
                
            }
            .padding(.top, 5) // Add padding to the top of the HStack

            Text("请连接RTK")
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding([.leading], 10) // Add padding to the left and bottom of the text
                .padding(.bottom, 5) // Additional bottom padding
                .padding(.top, 0)
                .frame(maxWidth: .infinity, alignment: .leading) // Align the text to the leading edge
        }
        .frame(maxWidth: 150, maxHeight: 60)
        .background(Color.gray.opacity(0.6))
        .cornerRadius(10)
    }

    func rtkConnected() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundColor(signalColor(signalStrength: rtkViewModel.rtkData.signalStrength))
                    .frame(width: 20, height: 20)
                    .padding(.leading, 10)
                Spacer()
                Text("RTK")
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                Button(action: {
                    isShowingRtkSettingPage.toggle()
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                }
                .sheet(isPresented: $isShowingRtkSettingPage) {
                                    RtkSettingView(viewModel: rtkViewModel,isPresented: $isShowingRtkSettingPage)
                                }
                .padding(.trailing, 10)
            }
            .padding(.top, 5)
            
            Text("RTK已连接")
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(.leading, 10)
                .padding(.bottom,1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            AccuracyIndicatorView(accuracyString: rtkViewModel.rtkData.horizontalAccuracy, title: "水平精度")
                .padding(.leading, 10)
                //.padding(.top, 1)
            AccuracyIndicatorView(accuracyString: rtkViewModel.rtkData.verticalAccuracy, title: "海拔精度")
                .padding(.leading, 10)
                //.padding(.top,1)
            
        }
        .frame(maxWidth: 150, maxHeight: 100)
        .background(Color.gray.opacity(0.6))
        .cornerRadius(10)
    }

    func signalColor(signalStrength: UInt8) -> Color {
        switch signalStrength {
        case 3:
            return .green
        case 1...2:
            return .yellow
        default:
            return .red
        }
    }

}

struct AccuracyIndicatorView: View {
    var accuracyString: String
    var title: String
    
    var accuracyFloat: Float? {
        return Float(accuracyString)
    }
    
    var formattedAccuracyString: String {
        if let accuracy = accuracyFloat {
            return String(format: "%.2f米", accuracy)
        } else {
            return "-"
        }
    }
    
    var body: some View {
        HStack {
            Text("\(title): ")
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Text(formattedAccuracyString)
                .font(.system(size: 14))
                .foregroundColor(accuracyFloat != nil ? accuracyColor(accuracy: accuracyFloat!) : .white)
        }
    }
    
    func accuracyColor(accuracy: Float) -> Color {
        switch accuracy {
        case ..<1:
            return .green
        case 1..<2:
            return .yellow
        default:
            return .red
        }
    }
}

struct GeoSensorView_Previews: PreviewProvider {
    static var previews: some View {
        GeoSensorView()
    }
}
