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
    
    @AppStorage("selectedLanguage") private var selectedLanguage = Locale.current.language.languageCode?.identifier ?? "en"
       var supportedLanguages: [String: String] {
           guard let languageCodes = Bundle.main.object(forInfoDictionaryKey: "CFBundleLocalizations") as? [String] else { return [:] }
           var languages: [String: String] = [:]
           languageCodes.forEach { code in
               let locale = Locale(identifier: code)
               let languageName = locale.localizedString(forLanguageCode: code) ?? code
               languages[code] = languageName
           }
           return languages
       }
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color(red: 0.05, green: 0.05, blue: 0.05, opacity: 1.0)
                Form {
                    AccountSenction
                    RtkSection
                    AboutSection
                }
            }
            .navigationTitle(NSLocalizedString("Setting", comment: "Setting"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar, .tabBar)
        }
    }
    
    private var AccountSenction: some View {
        Section(header: Text(NSLocalizedString("Account", comment: "Account"))) {
            Text("-")
        }
    }
    
    private var RtkSection: some View{
        Section(header: Text("RTK")) {
            Text("RTK "+NSLocalizedString("Setting", comment: "CopyRight"))
        }
    }
    
    private var AboutSection: some View{
        Section(header: Text(NSLocalizedString("About", comment: "Setting")),footer: HStack{ Text("SiteSight \(appVersion) \(buildNumber)")
            Spacer()
            Text("Copyright © 2023 Shanghai Xunzhi")}){
                NavigationLink(destination: VersionView()) {
                    HStack {
                        Text(NSLocalizedString("Version", comment: "Version"))
                        Spacer()
                        Text("\(appVersion) \(buildNumber)")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                }
                NavigationLink(destination: LicenseView()) {
                    Text(NSLocalizedString("Copyright", comment: "CopyRight"))
                }
                NavigationLink(destination: DeveloperView()) {
                    Text(NSLocalizedString("Developer", comment: "Developer"))
                }
//                Picker("Language", selection: $selectedLanguage) {
//                    ForEach(supportedLanguages.keys.sorted(), id: \.self) { key in
//                        Text(supportedLanguages[key] ?? key).tag(key)
//                    }
//                }
//                .onChange(of: selectedLanguage) { newValue in
//                    LocalizationManager.shared.setLanguage(newValue)
//                    // Additional logic to refresh the UI
//                }
            }
    }
    
}

#Preview {
    SettingTabpageView()
}
