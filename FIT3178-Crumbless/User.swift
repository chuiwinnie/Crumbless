//
//  User.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 17/5/2023.
//

import UIKit
import FirebaseFirestoreSwift

class User: NSObject, Codable  {
    var id: String?
    var email: String?
    var foodItems: [Food]?
    var consumedFoodItems: [Food]?
    var expiredFoodItems: [Food]?
}

// UserCodingKeys to ensure they are exculded from the encode & decode process
enum UserCodingKeys: String, CodingKey {
    case id
    case foodItems
    case consumedFoodItems
    case expiredFoodItems
}
