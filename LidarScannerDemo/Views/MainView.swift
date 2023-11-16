import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    @State private var showScanView = false
    @State private var shouldReloadMainTagView = false // State to trigger reload in MainTagView

    var body: some View {
        ZStack(alignment: .bottom) {
            mainTabView
        }
        .fullScreenCover(isPresented: $showScanView) {
            ScanView(uuid: UUID(),isPresenting: $showScanView)
        }
        .onChange(of: showScanView) { newValue in
                    if !newValue {
                        shouldReloadMainTagView = true // Set this to true when showScanView changes to false
                    }
                }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            MainTagView(shouldReload: $shouldReloadMainTagView) // Pass the binding to MainTagView
            .tabItem {
                Image(systemName: "house")
                Text(NSLocalizedString("homeTitle", comment: "Home tab title"))
            }
            .tag(0)
            Color.clear
                .tabItem {
                    Image(systemName: "plus.rectangle.fill")
                    Text(NSLocalizedString("scanTitle", comment: "Scan tab title"))
                }
                .tag(1)
                .onAppear {
                    self.showScanView = true
                    self.selectedTab = 0
                    
                }
            SettingTabpageView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text(NSLocalizedString("settingsTitle", comment: "Settings tab title"))
                }
                .tag(2)
        }
        .accentColor(.red)
    }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}

