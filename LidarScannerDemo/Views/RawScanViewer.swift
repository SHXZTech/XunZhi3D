//
//  RawScanViewer.swift
//  SwitchCameraTutorial
//
//  Created by Tao Hu on 2023/4/21.
//

import SwiftUI
import SceneKit
import ARKit

struct RawScanViewer: View {
    var uuid: UUID
    private var rawScanManager: RawScanManager
    @Binding var isPresenting: Bool

    init(uuid: UUID, isPresenting: Binding<Bool>) {
        self.uuid = uuid
        self.rawScanManager = RawScanManager(uuid: uuid)
        self._isPresenting = isPresenting
    }
    
    var body: some View {
        VStack {
            header
            content
            controls
        }
    }
    
    private var header: some View {
        HStack {
            Spacer()
            Text("Draft")
                .multilineTextAlignment(.center)
            Spacer()
            Button(action: {
                isPresenting = false  // This will dismiss the view and go back to MainView
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title)
            })
            .padding(.horizontal, 25)
        }
        .frame(height: 20)
        .padding(.vertical, 10)
    }
    
    private var content: some View {
        Group {
            if rawScanManager.isRawMeshExist() {
                ModelViewer(modelURL: rawScanManager.getRawMeshURL(), height: UIScreen.main.bounds.height * 0.5)
            } else {
                Text("Unable to load file mesh")
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5)
            }
        }
    }

    
    private var controls: some View {
        VStack {
            Toggle("4K Raw", isOn: .constant(false)).padding(.horizontal, 40)
            HStack {
                Text("Image number:")
                Spacer()
                Text("Est: 1min")
                Spacer()
                // Future button to upload to cloud
            }
            Text("Upload size: 100MB")
            Button("Upload & Process") {
                // Handle upload and process action
            }
            .buttonStyle(.borderedProminent)
            .frame(width: 360, height: 54, alignment: .center)
            .background(Color.blue)
            .foregroundColor(Color.white)
            .cornerRadius(13)
        }
    }
}

// Update your preview provider to pass a constant binding.
struct RawScanViewer_Previews: PreviewProvider {
    static var previews: some View {
        // Use constant binding for previews
        RawScanViewer(uuid: UUID(), isPresenting: .constant(true))
    }
}
