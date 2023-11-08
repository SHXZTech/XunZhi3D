//
//  SettingTabpageView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/7.
//

import SwiftUI

struct SettingTabpageView: View {
    let buildNumber = Bundle.main.object(forInfoDictionaryKey: "BundleVersionNumber") as? String ?? "Unknown"
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "BundleVersion") as? String ?? "Unknown"
    
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color(red: 0.05, green: 0.05, blue: 0.05, opacity: 1.0)
                Form {
                    Section(header: Text("账户")) {
                        Text("-")
                    }
                    Section(header: Text("RTK")) {
                        Text("RTK设置")
                    }
                    Section(header: Text("关于"),footer: HStack{ Text("SiteSight \(appVersion) \(buildNumber)")
                        Spacer()
                        Text("Copyright © 2023 Shanghai Xunzhi")}){
                            HStack {
                                Text("版本信息")
                                Spacer()
                                Text("\(appVersion) \(buildNumber)")
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                            }
                            NavigationLink(destination: LicenseView()) {
                                Text("版权信息")
                            }
                            //TODO
                            //                        NavigationLink(destination: DeveloperView()) {
                            //                            Text("Third Party License")
                            //                        }
                            NavigationLink(destination: DeveloperView()) {
                                Text("开发者")
                            }
                            //TODO
                            //Text("第三方版权")
                            //TODO add thirdparty licenses
                        }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar, .tabBar)
        }
    }
}

#Preview {
    SettingTabpageView()
}
