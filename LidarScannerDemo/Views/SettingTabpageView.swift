//
//  SettingTabpageView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/7.
//

import SwiftUI

struct SettingTabpageView: View {
    // Fetch the app version and build number from the Info.plist file
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
                    Section(footer: Text("SiteSight/景视 \(appVersion) \(buildNumber)")){
                        HStack {
                            Text("版本")
                            Spacer()
                            Text("\(appVersion) \(buildNumber)")
                                .foregroundColor(.gray)
                                .font(.footnote)
                        }
                        NavigationLink(destination: LicenseView()) {
                            Text("版权信息")
                        }
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
