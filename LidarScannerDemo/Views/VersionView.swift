import SwiftUI

struct VersionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
            VStack(alignment: .leading, spacing: 0) {
                Text("Beta 1.1").font(.title)
                Text("2024年01月18日，thomas").font(.footnote)
                Text("- 测量功能;\n- 管道绘制功能;\n- 公有云建模;\n- 邮件反馈.\n ")
                    .padding([.horizontal,.vertical],10)
            }
            .padding(.horizontal,20)
            .padding(.bottom, 8)
            Divider()
            VStack(alignment: .leading, spacing: 0) {
                Text("Beta 1.0").font(.title)
                Text("2023年12月22日，thomas").font(.footnote)
                Text("- 三维扫描功能;\n- 模型查看;\n- RTK连接.\n ")
                    .padding([.horizontal,.vertical],10)
            }
            .padding(.horizontal,20)
            .padding(.bottom, 8)
            Divider()
            VStack(alignment: .leading, spacing: 0) {
                Text("Alpha 0.2").font(.title)
                Text("2023年11月21日，thomas").font(.footnote)
                Text("- 完善项目查看功能，增加详细信息查看;\n- 增加RTK数据采集功能;\n- UI调整;\n- Bug修复.\n ")
                    .padding([.horizontal,.vertical],10)
            }
            .padding(.horizontal,20)
            .padding(.bottom, 8)
            Divider()
            VStack(alignment: .leading, spacing: 0) {
                Text("Alpha 0.1").font(.title)
                Text("2023年11月10日，thomas").font(.footnote)
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

