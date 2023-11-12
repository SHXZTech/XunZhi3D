import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    @State private var showScanView = false
    //@State private var isPresentingScanView = false

    
    var body: some View {
        ZStack(alignment: .bottom) {
            mainTabView
        }
        .fullScreenCover(isPresented: $showScanView) {
            ScanView(uuid: UUID(),isPresenting: $showScanView)
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            MainTagView()
            .tabItem {
                Image(systemName: "house")
                Text("主页")
            }
            .tag(0)
            Color.clear
                .tabItem {
                    Image(systemName: "plus.rectangle.fill")
                    Text("扫描")
                }
                .tag(1)
                .onAppear {
                    self.showScanView = true
                    self.selectedTab = 0
                }
            SettingTabpageView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("设置")
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

