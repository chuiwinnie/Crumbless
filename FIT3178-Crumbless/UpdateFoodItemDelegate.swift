//
//  UpdateFoodItemDelegate.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 3/5/2023.
//

import Foundation

protocol UpdateFoodItemDelegate: AnyObject {
    func updateFood(updatedFood: Food, rowId: Int) -> Bool
}
