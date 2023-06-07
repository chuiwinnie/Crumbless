//
//  Food.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 26/4/2023.
//

import UIKit
import FirebaseFirestoreSwift

class Food: NSObject, Codable {
    @DocumentID var id: String?
    var name: String?
    var expiryDate: Date?
    var alert: String?
    var alertTime: String?
}

// FoodCodingKeys to ensure they are exculded from the encode & decode process
enum FoodCodingKeys: String, CodingKey {
    case id
    case name
    case expiryDate
    case alert
    case alertTime
}
