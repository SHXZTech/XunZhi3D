import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0 // To track the currently selected tab
    private var theme_color_red =  Color(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1))
    init() {
    //UITabBar.appearance().backgroundColor = UIColor.black
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                MainTagView()
                .tabItem {
                    Image(systemName: "house")
                    Text("主页")
                }
                .tag(0)
               ScanView()
                    .tabItem {
//                        Image("Capture_red")
//                            .resizable()
//                            .scaledToFit()
//                            .imageScale(.medium)
                        Image(systemName: "plus.rectangle.fill")
                        Text("扫描")
                    }
                    .tag(1)
                SettingTabpageView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("设置")
                    }
                    .tag(2)
            }.accentColor(.red)
        }
    }
}



struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

