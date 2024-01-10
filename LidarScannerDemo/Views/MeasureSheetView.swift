//
//  MeasureSheetView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2024/1/10.
//

import SwiftUI


struct MeasureSheetView: View {
    @Binding var isPresented: Bool
    
    @Binding var measuredDistance: Double
    @Binding var isMeasuredFirstPoint: Bool
    @Binding var isReturnToInit: Bool
    
    var formattedDistance: String {
           let meters = Int(measuredDistance)
           let centimeters = Int((measuredDistance - Double(meters)) * 100)
           return "\(meters) \(NSLocalizedString("Meters", comment: "")) \(centimeters) \(NSLocalizedString("Centimeters", comment: ""))"
       }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding()
                    
                }
                .padding(.horizontal,10)
                Spacer()
                Text(NSLocalizedString("Measure", comment: ""))
                    .font(.title2)
                Spacer()
                Button(action: {
                    isReturnToInit = true
                }) {
                    Image(systemName: "return")
                        .foregroundColor(isMeasuredFirstPoint ? .white : .gray)
                        .font(.title2)
                        .padding()
                }
                .disabled(!isMeasuredFirstPoint)
                .padding(.horizontal,10)
            }
            Spacer()
            HStack{
                
                if measuredDistance > 0.00001 {
                    Text(formattedDistance)
                        .foregroundColor(.red)
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                } else {
                    Text(NSLocalizedString("tap anywhere to measure", comment: ""))
                }
            }
            Spacer()
        }
    }
}




struct MeasureSheetView_Previews: PreviewProvider {
    // Sample state variables for preview
    @State static var isPresented = true
    @State static var measuredDistance = 0.0
    @State static var isMeasuredFirstPoint = false
    @State static var isReturnToInit = false
    
    static var previews: some View {
        MeasureSheetView(isPresented: $isPresented,
                         measuredDistance: $measuredDistance,
                         isMeasuredFirstPoint: $isMeasuredFirstPoint,
                         isReturnToInit: $isReturnToInit)
        .background(Color.black.opacity(0.6)) // Optional: add a background for better visibility in preview
    }
}
