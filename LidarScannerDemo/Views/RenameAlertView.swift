//
//  RenameAlertView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2024/6/20.
//

import SwiftUI

struct RenameAlertView: View {
    @Binding var isPresented: Bool
    @Binding var captureName: String
    var onSave: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                TextField(NSLocalizedString("Enter new name", comment: ""), text: $captureName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack {
                    Button(NSLocalizedString("Cancel", comment: "")) {
                        isPresented = false
                    }
                    .padding()
                    
                    Button(NSLocalizedString("Save", comment: "")) {
                        onSave(captureName)
                        isPresented = false
                    }
                    .padding()
                }
            }
            .padding()
            .navigationBarTitle(NSLocalizedString("Rename Capture", comment: ""))
            .navigationBarItems(leading: Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
            })
        }
    }
}
