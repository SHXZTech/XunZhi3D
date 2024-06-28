import SwiftUI
import CryptoKit

struct RegisterPageView: View {
    @Binding var isPresented: Bool
    @State private var phoneNumber: String = ""
    @State private var password: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let cloudService = CloudService()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("注册")
                    .font(.system(size: 30))
                    .padding(.vertical, 10)
                Text("通过电话号码注册以使用")
                    .font(.subheadline)
                
                VStack(spacing: 15) {
                    TextField("电话号码", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(.systemGray))
                        .cornerRadius(8)
                    
                    SecureField("密码", text: $password)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(.systemGray))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
                
                GeometryReader { geometry in
                    Button(action: {
                        registerUser()
                    }) {
                        Text("注册")
                            .frame(width: geometry.size.width * 0.8)
                            .padding()
                            .background(isLoading ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .font(.headline)
                    }
                    .disabled(isLoading)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                .frame(height: 50)
                .padding(.vertical, 15)
                
                if isLoading {
                    ProgressView()
                }
            }
            .navigationBarItems(trailing:
                Button(action: { self.isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                }
            )
        }
    }
    


    private func registerUser() {
        isLoading = true
        errorMessage = nil
        
        // Hash the password
        let hashedPassword = SHA256.hash(data: password.data(using: .utf8)!)
            .compactMap { String(format: "%02x", $0) }
            .joined()
        
        cloudService.registerUser(phoneNumber: phoneNumber, hashed_password: hashedPassword) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    print("Registration successful: \(response)")
                    self.isPresented = false // Close the registration view
                case .failure(let error):
                    switch error {
                    case let cloudError as CloudServiceError:
                        switch cloudError {
                        case .invalidURL:
                            self.errorMessage = "Invalid URL. Please try again later."
                        case .serverError(let statusCode):
                            self.errorMessage = "Server error: \(statusCode). Please try again later."
                        case .decodingError:
                            self.errorMessage = "Error processing server response. Please try again."
                        case .noData:
                            self.errorMessage = "No data received from server. Please try again."
                        case .unknown:
                            self.errorMessage = "An unknown error occurred. Please try again."
                        }
                    default:
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}
