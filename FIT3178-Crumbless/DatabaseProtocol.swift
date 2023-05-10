//
//  DatabaseProtocol.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 10/5/2023.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case foodItems
    case consumedFoodItems
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onFoodItemsChange(change: DatabaseChange, foodItems: [Food])
    func onConsumedFoodItemsChange(change: DatabaseChange, consumedFoodItems: [Food])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addFood(name: String, expiryDate: Date, alert: String) -> Food
    func updateFood(food: Food)
    func deleteFood(food: Food)
    
    func addConsumedFood(food: Food) -> Food
}
