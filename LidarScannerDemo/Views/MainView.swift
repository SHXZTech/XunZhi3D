import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0
    @State private var showScanView = false
    @State private var showCaptureView = false
    @State private var showRawScanView = false
    @State var shouldReloadMaintagView = false
    @State var currentUUID = UUID()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            mainTabView
        }
        .fullScreenCover(isPresented: $showScanView) {
            ScanView(uuid: currentUUID,isPresenting: $showScanView, isRawScanPresenting: $showRawScanView)
        }
        .fullScreenCover(isPresented: $showRawScanView) {
            RawScanView(uuid: currentUUID, isPresenting: $showRawScanView)
        }
        .onChange(of: showScanView) { newValue in
            if newValue {
                currentUUID = UUID()
            }
            if !newValue {
                shouldReloadMaintagView = true
            }
        }
        
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            MainTagView(shouldReload: $shouldReloadMaintagView)
                .tabItem {
                    Image(systemName: "house")
                    Text(NSLocalizedString("homeTitle", comment: "Home tab title"))
                }
                .tag(0)
            Color.clear
                .tabItem {
                    Image(systemName:"plus.rectangle.fill")
                        .resizable()
                    Text(NSLocalizedString("scanTitle", comment: "Scan tab title"))
                }
                .tag(1)
                .onAppear {
                    self.showScanView = true
                    self.selectedTab = 0
                }
            SettingTabpageView()
                .tabItem {
                    Image(systemName: "gear")
                    Text(NSLocalizedString("Setting", comment: "Settings tab title"))
                }
                .tag(2)
        }
        .accentColor(Color.white)
        .background(Color.black)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

