//
//  RawScanViewer.swift
//  SiteSight
//
//  Created by Tao Hu on 2023/4/21.
//

import SwiftUI
import SceneKit
import ARKit

struct RawScanView: View {
    var uuid: UUID
    var rawScanManager: RawScanManager
    @Binding var isPresenting: Bool
    @State private var showingExitConfirmation = false

    init(uuid: UUID, isPresenting: Binding<Bool>) {
        self.uuid = uuid
        self.rawScanManager = RawScanManager(uuid: uuid)
        self._isPresenting = isPresenting
    }
    
    var body: some View {
        VStack {
            header
            Spacer()
            content
            Spacer()
            controls
                .padding(.vertical, 20)
        }
    }
    
    private var header: some View {
        ZStack {
            HStack {
                Spacer()
                Button(action: {
                    //isPresenting = false  // This will dismiss the view and go back to MainView
                    //rawScanManager.deleteProjectFolder()
                    self.showingExitConfirmation = true
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                })
                .padding(.horizontal, 25)
                .actionSheet(isPresented: $showingExitConfirmation) {
                                    ActionSheet(
                                        title: Text("确认退出?"),
                                        message: Text("删除草稿将删除所有采集的数据"),
                                        buttons: [
                                            .destructive(Text("删除草稿")) {
                                                isPresenting = false
                                                rawScanManager.deleteProjectFolder()
                                            },
                                            .default(Text("保存草稿")) {
                                                isPresenting = false
                                            },
                                            .cancel()
                                        ]
                                    )
                                }
            }
            
            Text("草稿")
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 10)
    }

    
    private var content: some View {
        Group {
            if rawScanManager.isRawMeshExist() {
                ModelViewer(modelURL: rawScanManager.getRawMeshURL(), height: .infinity)
            } else {
                Text("无法加载模型")
                    .frame(width: UIScreen.main.bounds.width, height: .infinity)
            }
        }
    }

    
    private var controls: some View {
        VStack {
           
            Button("上传并处理") {
                isPresenting = false
                //TODO
                // Handle upload and process action
            }
            .frame(width: 360, height: 54, alignment: .center)
            .background(Color.blue)
            .foregroundColor(Color.white)
            .cornerRadius(13)
            .frame(width: 360, height: 54, alignment: .center)
            .background(Color.red)
            .foregroundColor(Color.white)
            .cornerRadius(13)
            
            HStack() {
                Text("图像数量: \(rawScanManager.raw_scan_model.frameCount)")  
                    .font(.footnote)
                Spacer()
                Text("预计传输时间: 1min")
                    .font(.footnote)
                // Future button to upload to cloud
            }
            .padding(.horizontal,40)
        }
    }
}

// Update your preview provider to pass a constant binding.
struct RawScanViewer_Previews: PreviewProvider {
    static var previews: some View {
        // Use constant binding for previews
        RawScanView(uuid: UUID(), isPresenting: .constant(true))
    }
}
