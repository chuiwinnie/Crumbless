//
//  AddNewFoodItemDelegate.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 26/4/2023.
//

import Foundation

protocol AddNewFoodItemDelegate: AnyObject {
    func addFood(_ newFood: Food) -> Bool
}
