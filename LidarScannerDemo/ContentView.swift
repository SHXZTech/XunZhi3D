//
//  ContentView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/4/21.
//

import SwiftUI
import RealityKit
import SceneKit
import ARKit

struct ContentView : View {
   
    var body: some View {
        MainView()
            .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/) // force dark theme
    }
}




#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
