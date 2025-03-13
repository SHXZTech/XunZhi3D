//
//  MainTagView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/7.
//

import SwiftUI

struct MainTagView: View {
    
    @StateObject var viewModel = MainTagViewModel()
    
    @State var showCapture = false
    
    @Binding var shouldReload: Bool
    @Environment(\.colorScheme) var colorScheme
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16), // Assuming some spacing between items
        GridItem(.flexible(), spacing: 16)
    ]
    
    init(shouldReload: Binding<Bool>) {
        self._shouldReload = shouldReload
    }
    
    private var backgroundColor: Color {
        Color.black
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                VStack{
                    customNavigationBar
                        .frame(height: 30)
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 40) {
                            ForEach(viewModel.captures, id: \.id) { capture in
                                CapturePreviewView(capture: capture) {
                                    viewModel.selectCapture(uuid: capture.id)
                                    showCapture = true
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showCapture) {
            if viewModel.isSelectedCaptureProcessed ?? false{
                
                CaptureView(uuid: viewModel.selectedCaptureUUID!, isPresenting: $showCapture)
                    .onAppear(){
                        print("调用CaptureView方法== == ==，viewModel.selectedCaptureUUID== == ==",viewModel.selectedCaptureUUID)
                    }
            }else{
                RawScanView(uuid: viewModel.selectedCaptureUUID!, isPresenting: $showCapture)
                    .onAppear(){
                        print("调用RawScanView方法== == ==，viewModel.selectedCaptureUUID== == ==",viewModel.selectedCaptureUUID)
                    }
            }
        }
        .onChange(of: shouldReload) { newValue in
            if newValue {
                viewModel.loadCaptures()
                shouldReload = false // Reset the flag after loading
            }
        }
        .onChange(of: showCapture){newValue in
            if(showCapture == false){
                shouldReload = true;
            }
        }
    }
    
    private var customNavigationBar: some View {
           VStack {
               HStack {
                   Spacer()
                   Text(NSLocalizedString("XunZhi3D", comment: ""))
                       .font(.system(size: 20))
                       .foregroundColor(.white)
                   Spacer()
               }
               .background(Color.black) // Custom navigation bar background color
           }
       }
    
    private var sortedCaptures: [CapturePreviewModel] {
        viewModel.captures.sorted { $0.date > $1.date }
    }
    
}

// MARK: - Preview

struct MainTagView_Previews: PreviewProvider {
    static var previews: some View {
        MainTagView(shouldReload: .constant(false))
    }
}




