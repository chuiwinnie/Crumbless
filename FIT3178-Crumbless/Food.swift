//
//  Food.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 26/4/2023.
//

import UIKit

class Food: NSObject {
    var name: String
    var expiryDate: Date
    var alert: Bool?
    
    init(name: String, expiryDate: Date) {
        self.name = name
        self.expiryDate = expiryDate
    }
}
