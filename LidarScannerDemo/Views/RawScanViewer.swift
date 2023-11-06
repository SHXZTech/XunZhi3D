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
    var uuid:UUID
    private var rawScanManager : RawScanManager
    
    init(uuid: UUID) {
        self.uuid = uuid
        self.rawScanManager = RawScanManager(uuid: uuid)
    }
    
    var body: some View {
        VStack{
                HStack{
                    Spacer()
                    Text("Draft")
                        .multilineTextAlignment(.center)
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                    })
                    .padding(.horizontal, 25)
                }
            .frame(height: 20)
            .padding(.vertical,10)
            Spacer()
            if(rawScanManager.isRawMeshExist)
            {
                ModelViewer(modelURL: rawScanManager.getRawMeshURL(),height: UIScreen.main.bounds.height*0.5)
            }
            else{
                Text("unable to load file: \(rawScanManager.getRawMeshURL().path)")
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.5)
            }
            Spacer()
            VStack{
                Toggle("4K Raw", isOn: .constant(false)).padding(.horizontal,40)
                HStack{
                    Text("Image number:")
                    Spacer()
                    Text("Est: 1min")
                    Spacer()
                    //Button(action: , label: Text("Upload to cloud"))
                }
                Text("Upload size: 100MB")
                Button("upload & process"){}
                    .buttonStyle(.borderedProminent)
                    .frame(width:360, height: 54,alignment: .center)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(13)
            }
        }
    }
    


}

struct RawScanViewer_Previews: PreviewProvider {
    static var previews: some View {
        RawScanViewer(uuid:UUID())
    }
}
