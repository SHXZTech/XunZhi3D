//
//  LoginPageView.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2024/6/21.
//

import SwiftUI

struct LoginPageView: View {
    @Binding var isPresented: Bool
    @State private var isShowRegisterSheet: Bool = false
    @State private var phoneNumber: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center){
                Text("登录")
                    .font(.system(size: 30))
                    .padding(.vertical,10)
                Text("通过电话号码登录以使用")
                    .font(.subheadline)
                
                VStack(spacing: 15) {
                    TextField("电话号码", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(.systemGray))
                        .cornerRadius(8)
                    
                    SecureField("密码", text:$password)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(.systemGray))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                Button(action:{self.isShowRegisterSheet = true}){
                    Text("注册新帐号")
                }
                .padding(.vertical,10)
                
                Spacer()
                GeometryReader { geometry in
                    Button(action: {
                        // Action for logout
                    }) {
                        Text("登录")
                            .frame(width: geometry.size.width * 0.8)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .font(.headline)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                .frame(height: 50)  // Adjust this value as needed
                .padding(.vertical,15)
            }
            .navigationBarItems(trailing:
                                    Button(action:{self.isPresented = false}){
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
            }
            )
            .sheet(isPresented: $isShowRegisterSheet) {
                RegisterPageView(isPresented: $isShowRegisterSheet)
            }
        }
    }
}

