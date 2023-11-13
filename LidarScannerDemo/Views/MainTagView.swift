//
//  MainTagView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/7.
//

import SwiftUI

struct MainTagView: View {
    
    @StateObject var viewModel = MainTagViewModel()
    @State private var selectedCapture: CapturePreviewModel? // State to track selected capture
    
    
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16), // Assuming some spacing between items
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.05, opacity: 1.0).ignoresSafeArea()
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 40) {
                        ForEach(viewModel.captures, id: \.id) { capture in
                            CapturePreviewView(capture: capture){
                                self.selectedCapture = capture // Set the selected capture
                            }
                        }
                    }
                    .padding() // Add padding around the grid
                }
            }
            .navigationTitle(NSLocalizedString("SiteSight", comment: "Product Name"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .background(NavigationLink("", isActive: isNavigationActive) {
                if let selected = selectedCapture {
                    RawScanView(uuid: selected.id, isPresenting: .constant(true)) // Modify according to your RawScanView initializer
                }
            }.hidden())
        }
    }
    
    private var sortedCaptures: [CapturePreviewModel] {
        viewModel.captures.sorted { $0.date > $1.date }
    }
    
    private var isNavigationActive: Binding<Bool> {
        Binding(
            get: { self.selectedCapture != nil },
            set: { isActive in
                if !isActive {
                    self.selectedCapture = nil
                }
            }
        )
    }
}

// MARK: - Preview

struct MainTagView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a MainTagView with a predefined set of captures for preview purposes
        MainTagView(viewModel: MainTagViewModel(captures: []))
    }
}


