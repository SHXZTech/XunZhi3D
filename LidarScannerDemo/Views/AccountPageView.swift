//
//  AccountPageView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2024/6/21.
//

import SwiftUI

struct AccountPageView: View {
    @Binding var isPresented: Bool
    //@ObservedObject var viewModel: AccountViewModel
    @StateObject private var viewModel: AccountViewModel
    @State private var showNameEditBox = false
    @State private var showOrganizationEditBox = false
    @State private var newName: String = ""
    @State private var newOrganizationName: String = ""
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        let accountService = AccountService()
        let viewModel = AccountViewModel(accountService: accountService)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center){
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                Text(viewModel.account.Name)
                    .font(.title)
                Text(viewModel.account.OrganizationName)
                    .font(.subheadline)
                Form{
                    Section (header: Text(NSLocalizedString("帐号信息", comment: "Setting"))){
                        Button(action: {
                            newName = viewModel.account.Name
                            showNameEditBox = true
                        }) {
                            HStack {
                                Text("账户名")
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(viewModel.account.Name)
                                    .foregroundColor(.white)
                                    .font(.footnote)
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 10, height: 10)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .alert("设置账户名", isPresented: $showNameEditBox, actions: {
                            TextField(viewModel.account.Name, text: $newName)
                                .foregroundColor(.black)
                            Button("Sure", action: {viewModel.updateName(newName)})
                            Button("Cancel", role: .cancel, action: {showNameEditBox=false})
                        })
                        
                        Button(action: {
                            newOrganizationName = viewModel.account.OrganizationName
                            showOrganizationEditBox = true
                        }) {
                            HStack {
                                Text("所属组织")
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(viewModel.account.OrganizationName)
                                    .foregroundColor(.white)
                                    .font(.footnote)
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 10, height: 10)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .alert("设置所属组织", isPresented: $showOrganizationEditBox, actions: {
                            TextField(viewModel.account.OrganizationName, text: $newOrganizationName)
                                .foregroundColor(.black)
                            Button("Sure", action: {viewModel.updateOrganizationName(newOrganizationName)})
                            Button("Cancel", role: .cancel, action: {showOrganizationEditBox=false})
                        })
                    }
                    
                    Section {
                        Button(action: {
                            
                        }) {
                            HStack {
                                Text("修改密码")
                                    .foregroundStyle(.blue)
                            }
                        }
                        Button(action: {
                            
                        }) {
                            HStack {
                                Text("删除账号")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
                Spacer()
                GeometryReader { geometry in
                    Button(action: {
                        // Action for logout
                    }) {
                        Text("退出登录")
                            .frame(width: geometry.size.width * 0.8)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .font(.headline)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                .frame(height: 50)  // Adjust this value as needed
                .padding(.vertical,15)
            }
            .navigationBarTitle("账户", displayMode: .inline)
            .navigationBarItems(trailing: Button("完成") {
                self.isPresented = false
            }.foregroundColor(.blue))
        }
    }
}

