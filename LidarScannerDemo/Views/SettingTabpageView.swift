//
//  SettingTabpageView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/7.
//

import SwiftUI

struct SettingTabpageView: View {
    @State private var isAccountPagePresented = false
    @State private var isLoginPagePresented = false
    @StateObject private var accountViewModel: AccountViewModel
    
    
    let buildNumber = Bundle.main.object(forInfoDictionaryKey: "BundleVersionNumber") as? String ?? "Unknown"
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "BundleVersion") as? String ?? "Unknown"
    @AppStorage("selectedLanguage") private var selectedLanguage = Locale.current.language.languageCode?.identifier ?? "en"
    
    init() {
        let accountService = AccountService()
        let accountViewModel = AccountViewModel(accountService: accountService)
        self._accountViewModel = StateObject(wrappedValue: accountViewModel)
    }
    
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
                    AccountSection
                    //RtkSection
                    AboutSection
                }
            }
            .navigationTitle(NSLocalizedString("Setting", comment: "Setting"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar, .tabBar)
        }
        .sheet(isPresented: $isAccountPagePresented) {
            AccountPageView(isPresented: $isAccountPagePresented)
        }
        .sheet(isPresented: $isLoginPagePresented){
            LoginPageView(isPresented: $isLoginPagePresented)
        }
    }
    
    private var AccountSection: some View {
        Section(header: Text(NSLocalizedString("Account", comment: "Account"))) {
            HStack{
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading){
                    Text(accountViewModel.account.Name)
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    Text(accountViewModel.account.OrganizationName)
                        .font(.subheadline)
                }
                .padding(.horizontal,10)
                Spacer()
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.gray)
            }
        }
        .onTapGesture {
            if (accountViewModel.isAccountActive == true){
                isAccountPagePresented = true}
            else{
                isLoginPagePresented = true}
        }
    }
    
    private var RtkSection: some View{
        Section(header: Text("RTK")) {
            Text("RTK "+NSLocalizedString("Setting", comment: "CopyRight"))
        }
    }
    
    private var AboutSection: some View{
        Section(header: Text(NSLocalizedString("About", comment: "Setting")),
                footer: VStack(alignment:.leading){ Text("XunZhi3D \(appVersion) \(buildNumber)")
            Text("Copyright © 2024 Shanghai Xunzhi")}){
                NavigationLink(destination: VersionView()) {
                    HStack {
                        Text(NSLocalizedString("Version", comment: "Version"))
                        Spacer()
                        Text("\(appVersion) \(buildNumber)")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                }
                Link(destination: URL(string: "mailto:cs@xztech.xyz;cx@xztech.xyz")!) {
                    Text(NSLocalizedString("Feedback", comment: "Feedback"))
                }
            }
    }
    
}

