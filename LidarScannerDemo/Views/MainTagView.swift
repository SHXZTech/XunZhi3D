//
//  MainTagView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/7.
//

import SwiftUI

struct MainTagView: View {
    
    @StateObject var viewModel = MainTagViewModel()
   
    @State var showCapture:Bool
    
    @Binding var shouldReload: Bool
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16), // Assuming some spacing between items
        GridItem(.flexible(), spacing: 16)
    ]
    
    init(shouldReload: Binding<Bool>) {
        self._shouldReload = shouldReload
        self.showCapture = false
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.05, opacity: 1.0).ignoresSafeArea()
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
            .navigationTitle(Text("SiteSight"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
        }
        .fullScreenCover(isPresented: $showCapture) {
            CaptureView(uuid: viewModel.selectedCaptureUUID!, isPresenting: $showCapture)
        }
        .onChange(of: shouldReload){newValue in
                print("MainTagView triggle shouldReloadMaintagView = true")
                viewModel.loadCaptures()
                shouldReload = false
        }
        .onChange(of: showCapture){newValue in
            if(showCapture == false){
                shouldReload = true;
            }
        }
    }
    
    private var sortedCaptures: [CapturePreviewModel] {
        viewModel.captures.sorted { $0.date > $1.date }
    }

}

// MARK: - Preview

struct MainTagView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a MainTagView with a predefined set of captures for preview purposes
        //MainTagView(viewModel: MainTagViewModel(captures: []))
        Text("Hello world")
    }
}


