//
//  SwiftUIView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/8.
//

import SwiftUI

struct TestView: View {
    @State private var selection = 0
    var body: some View {
        NavigationView {
            TabView(selection: $selection) {
                Text("First View")
                    .tabItem {
                        Image(systemName: "1.circle")
                        Text("First")
                    }
                    .tag(0)
                NavigationLink(destination: DetailView()) {
                   
                }
                Text("Second View")
                    .tabItem {
                        Image(systemName: "2.circle")
                        Text("Second")
                    }
                    .tag(1)
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                UITabBar.appearance().isHidden = true
            }
            .onDisappear {
                UITabBar.appearance().isHidden = false
            }
        }
    }
}

struct DetailView: View {
    var body: some View {
        VStack {
            Text("Detail View")
            Button(action: {
                // Navigate back to the main view
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
            }) {
                Text("Exit")
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            UITabBar.appearance().isHidden = true
        }
        .onDisappear {
            UITabBar.appearance().isHidden = false
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
