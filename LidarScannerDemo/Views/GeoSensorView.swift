//
//  GeoSensorView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/10/18.
//

import SwiftUI

struct GeoSensorView: View {
    @ObservedObject var rtkViewModel: RTKViewModel
    @State private var isShowingRtkSettingPage = false // State to control the presentation of the sheet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if rtkViewModel.selectedDevice == nil {
                noRtkConnected()
            }
            else{
                rtkConnected()
            }
            Spacer()
        }
    }
    
    init(viewModel: RTKViewModel) {
        self.rtkViewModel = viewModel
    }
    
    func noRtkConnected() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            RTKConnectionIndicatorView(rtkViewModel: rtkViewModel,
                                       title: "RTK",
                                       isShowingRtkSettingPage: $isShowingRtkSettingPage)
            .frame(maxWidth: 150, maxHeight: 30, alignment: .leading)
            .padding(.top,0.01)
            Spacer()
            RTKStatusView(isConnected: false, signalStrength: rtkViewModel.rtkData.signalStrength)
                .padding(.leading, 10)
                .padding(.bottom,10)
        }
        .frame(maxWidth: 150, maxHeight: 60)
        .background(Color.gray.opacity(0.6))
        .cornerRadius(10)
    }
    
    func rtkConnected() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            RTKConnectionIndicatorView(rtkViewModel: rtkViewModel,
                                       title: "RTK",
                                       isShowingRtkSettingPage: $isShowingRtkSettingPage)
            .frame(maxWidth: 150, maxHeight: 30, alignment: .leading)
            .padding(.top,0)
            Spacer()
            
            RTKStatusView(isConnected: true, signalStrength: rtkViewModel.rtkData.signalStrength)
                .frame(maxWidth: 150, maxHeight: 30, alignment: .leading)
                .padding(.leading, 10)
                .padding(.bottom,1)
            
            AccuracyIndicatorView(accuracyString: rtkViewModel.rtkData.horizontalAccuracy, title: "水平精度")
                .frame(maxWidth: 150, maxHeight: 30, alignment: .leading)
                .padding(.leading, 10)
            AccuracyIndicatorView(accuracyString: rtkViewModel.rtkData.verticalAccuracy, title: "高程精度")
                .frame(maxWidth: 150, maxHeight: 30, alignment: .leading)
                .padding(.leading, 10)
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
            if accuracy > 100 || accuracy < 0.0 {
                return "-"
            } else {
                return String(format: "%.2f", accuracy)
            }
        } else {
            return "-"
        }
    }

    
    var body: some View {
        HStack {
            Text("\(title): ")
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(formattedAccuracyString)
                .font(.system(size: 14))
                .foregroundColor(accuracyFloat != nil ? accuracyColor(accuracy: accuracyFloat!) : .white)
            
            Text("米")
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(.trailing)
        }
    }
    
    func accuracyColor(accuracy: Float) -> Color {
        switch accuracy {
        case ..<0.1:
            return .green
        case 0.1..<0.5:
            return .yellow
        default:
            return .red
        }
    }
}

struct RTKStatusView: View {
    var isConnected: Bool
    var signalStrength: UInt8?
    
    var body: some View {
        Group {
            if isConnected {
                HStack {
                    Text("信号强度:")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    Text(formattedSignalStrength)
                        .font(.system(size: 14))
                        .foregroundColor(signalColor(signalStrength: signalStrength))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("RTK未连接")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    var formattedSignalStrength: String {
        guard let strength = signalStrength else {
            return "-"
        }
        
        switch strength {
        case 0:
            return "单点解"
        case 1:
            return "码差分"
        case 2:
            return "浮点解"
        case 3:
            return "固定解"
        default:
            return "\(strength)"
        }
    }
    
    func signalColor(signalStrength: UInt8?) -> Color {
        guard let strength = signalStrength else {
            return .white
        }
        
        switch strength {
        case 3:
            return .green
        case 1...2:
            return .yellow
        case 0:
            return .red
        default:
            return .red
        }
    }
}

struct RTKConnectionIndicatorView: View {
    @ObservedObject var rtkViewModel: RTKViewModel
    var title: String
    @Binding var isShowingRtkSettingPage: Bool
    
    var isConnected: Bool {
        rtkViewModel.selectedDevice != nil
    }
    
    var body: some View {
        HStack {
            Image(systemName: isConnected ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                .foregroundColor(isConnected ? signalColor(signalStrength: rtkViewModel.rtkData.signalStrength) : .red)
                .frame(width: 20, height: 20)
                .padding(.leading, 10)
            
            Spacer()
            
            Text(title)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            Button(action: {
                isShowingRtkSettingPage.toggle()
            }) {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
            }
            .padding(.trailing, 10)
            .sheet(isPresented: $isShowingRtkSettingPage) {
                RtkSettingView(viewModel: rtkViewModel, isPresented: $isShowingRtkSettingPage)
            }
        }
        .padding(.top, 5)
        .padding(.bottom, 5)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.6))
        .clipShape(RoundedCorner(radius: 10, corners: [.topLeft, .topRight]))
    }
    
    func signalColor(signalStrength: UInt8?) -> Color {
        guard let strength = signalStrength else {
            return .white
        }
        
        switch strength {
        case 3:
            return .green
        case 1...2:
            return .yellow
        default:
            return .red
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct GeoSensorView_Previews: PreviewProvider {
    static var previews: some View {
        GeoSensorView(viewModel: RTKViewModel())
    }
}
