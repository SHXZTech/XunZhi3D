import SwiftUI

struct VersionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Alpha 0.2").font(.title)
                Text("11月21日").font(.footnote)
                Text("- 完善项目查看功能，增加详细信息查看;\n- 增加RTK数据采集功能;\n- UI调整;\n- Bug修复.\n ")
                    .padding([.horizontal,.vertical],10)
            }
            .padding(.horizontal,20)
            .padding(.bottom, 8)

            Divider()

            VStack(alignment: .leading, spacing: 0) {
                Text("Alpha 0.1").font(.title)
                Text("11月10日").font(.footnote)
                Text("测试版首次发布。")
                    .padding([.horizontal,.vertical],10)
            }
            .padding(.horizontal,20)
            .padding(.bottom, 8)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationTitle(NSLocalizedString("Version", comment: "Version"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct VersionView_Previews: PreviewProvider {
    static var previews: some View {
        VersionView()
    }
}

