//
//  AddToRecipeSearchDelegate.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 26/4/2023.
//

import Foundation

// Delegate for adding food items to recipe search
protocol AddToRecipeSearchDelegate: AnyObject {
    func addFood(_ newFood: Food) -> Bool
}
