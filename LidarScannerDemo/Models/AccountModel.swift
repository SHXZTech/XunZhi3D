//
//  AccountModel.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2024/6/21.
//

import Foundation

struct AccountModel: Codable {
    var UserId: UUID?
    var Name:String
    var Email:String
    var Phone:String
    var OrganizationName: String
    var OrganizationID:UUID?
    var UserToken:String
}
