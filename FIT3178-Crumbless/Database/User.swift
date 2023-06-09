//
//  User.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 17/5/2023.
//

import UIKit
import FirebaseFirestoreSwift

class User: NSObject, Codable  {
    var name: String?
    var email: String?
    var foodItems: [Food]?
    var consumedFoodItems: [Food]?
    var expiredFoodItems: [Food]?
}

enum UserCodingKeys: String, CodingKey {
    case name
    case email
    case foodItems
    case consumedFoodItems
    case expiredFoodItems
}
