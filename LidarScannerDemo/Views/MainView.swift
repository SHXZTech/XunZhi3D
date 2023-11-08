import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    @State private var showScanView = false // A state to control the visibility of ScanView
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                MainTagView()
                .tabItem {
                    Image(systemName: "house")
                    Text("主页")
                }
                .tag(0)
                
                // Placeholder view for the Scan tab
                Color.clear
                    .tabItem {
                        Image(systemName: "plus.rectangle.fill")
                        Text("扫描")
                    }
                    .tag(1)
                    .onAppear {
                        self.showScanView = true // Show the ScanView when the second tab is selected
                    }
                
                SettingTabpageView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("设置")
                    }
                    .tag(2)
            }
            .accentColor(.red)

            if showScanView {
                ScanView() {
                    // This closure is called when the exit button in ScanView is pressed
                    self.showScanView = false
                    self.selectedTab = 0 // Return to the first tab if needed
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}

