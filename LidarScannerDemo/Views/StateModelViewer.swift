//
//  ModelViewer.swift
//  scenemesh
//
//  Created by Tao Hu on 2023/4/6.
//

import SwiftUI
import SceneKit




struct StateModelViewer: View {
    @Binding var modelURL: URL?
    var width = UIScreen.main.bounds.width
    var height = UIScreen.main.bounds.height
    @ObservedObject var delegate = SceneRendererDelegate()
    
    var body: some View {
        ZStack {
            if let url = modelURL{
                LoadingView()
                ObjModelView(objURL: url)
                    .frame(width: width, height: height)
            }
            else{
                Text(NSLocalizedString("No model to display", comment: ""))
            }
        }
    }
}



//struct ModelViewer_Previews: PreviewProvider {
//    static var previews: some View {
//        let modelURL = Bundle.main.url(forResource: "textured", withExtension: "obj")!
//        return ModelViewer(modelURL: modelURL)
//    }
//}


