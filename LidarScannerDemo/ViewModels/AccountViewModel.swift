//
//  AccountViewModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2024/6/21.
//

import Foundation
import Combine

class AccountViewModel: ObservableObject {
    @Published var account: AccountModel
    @Published var isAccountActive: Bool
    private let accountService: AccountService
    
    init(accountService: AccountService) {
        self.accountService = accountService
        (self.account, self.isAccountActive) = accountService.loadAccount()
    }
    
    func updateName(_ newName: String) {
        account.Name = newName
        saveAccount()
    }
    
    func updateOrganizationName(_ newOrgName: String) {
        account.OrganizationName = newOrgName
        saveAccount()
    }
    
    private func saveAccount() {
        accountService.saveAccount(account)
        // Here you might also want to trigger a sync with the server
        accountService.syncWithServer()
    }
}
