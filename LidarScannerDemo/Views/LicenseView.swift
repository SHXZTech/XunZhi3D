//
//  LicenseView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/7.
//

import SwiftUI

struct LicenseView: View {
    var body: some View {
        Text("版权所有©2023 \n上海巡智科技有限公司\n保留所有权利\n未经上海巡智科技有限公司所有人事先书面同意，任何人不得以任何形式使用、复制、修改、合并、出版、分发、再许可和/或销售本软件。如需使用本软件，请与上海巡智科技有限公司联系。\n\nCopyright © 2023 \nShanghai Xunzhi Technology Ltd.\nAll Rights Reserved.\nThis software and its associated documentation are the exclusive property of Shanghai Xunzhi Tech. Ltd. Any unauthorized use, duplication, modification, distribution, or any other actions without express written permission from Shanghai Xunzhi Tech. Ltd. are strictly prohibited.If you wish to utilize, license, or have questions regarding this software, please directly contact Shanghai Xunzhi Tech. Ltd. For permissions and other inquiries, please contact: [thomas@graphopti.com]")
                   .padding()
                   .navigationTitle("版权信息")
                   .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LicenseView()
}
