//
//  AccountService.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2024/6/21.
//

import Foundation

class AccountService {
    private let userDefaults = UserDefaults.standard
    private let accountKey = "accountInfo"
    
    func saveAccount(_ account: AccountModel) {
        if let encodedData = try? JSONEncoder().encode(account) {
            userDefaults.set(encodedData, forKey: accountKey)
        }
    }
    
    func loadAccount() -> (AccountModel, Bool) {
        guard let data = userDefaults.data(forKey: accountKey),
              let decodedAccount = try? JSONDecoder().decode(AccountModel.self, from: data) else {
            // Return a default account and false if no data or decoding fails
            return (AccountModel(UserId: UUID(),
                                 Name: "未登录",
                                 Email: "",
                                 Phone: "",
                                 OrganizationName: "-",
                                 OrganizationID: UUID(),
                                 UserToken: ""), false)
        }
        return(decodedAccount, true)
    }
    
    func register(name: String, email: String, phone: String, password: String, organizationName: String) -> Bool {
        // Create a new AccountModel with the registration data
        let newAccount = AccountModel(
            UserId: nil,
            Name: name,
            Email: email,
            Phone: phone,
            OrganizationName: organizationName,
            OrganizationID: nil,  // You might want to handle this differently
            UserToken: UUID().uuidString
        )
        
        //TODO: register to server
        
        // Save the password securely (Note: In a real app, you should use Keychain for passwords)
        userDefaults.set(password, forKey: "userPassword")
        
        // Save the new account
        saveAccount(newAccount)
        
        
        return true  // Return true if registration was successful
    }
    
    // Add methods for API communication here
    func syncWithServer() {
        // Implement server synchronization logic
    }
}
