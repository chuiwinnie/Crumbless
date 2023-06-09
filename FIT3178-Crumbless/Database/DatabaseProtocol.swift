//
//  DatabaseProtocol.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 10/5/2023.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift

enum DatabaseChange {
    case add
    case update
    case remove
}

enum ListenerType {
    case foodItems
    case consumedOrExpiredFoodItems
    case users
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onFoodItemsChange(change: DatabaseChange, foodItems: [Food])
    func onConsumedFoodItemsChange(change: DatabaseChange, consumedFoodItems: [Food])
    func onExpiredFoodItemsChange(change: DatabaseChange, expiredFoodItems: [Food])
    func onUsersChange(change: DatabaseChange, users: [User])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    // Food itmes
    func addFood(name: String, expiryDate: Date, alert: String, alertTime: String) -> Food
    func updateFood(food: Food)
    func deleteFood(food: Food)
    
    // Consumed food items
    func addConsumedFood(food: Food) -> Food
    
    // Expired food items
    func addExpiredFood(food: Food) -> Food
    
    // Users
    var user: User? { get }
    var userDefaults: UserDefaults? { get }
    var userSignedIn: Bool? { get }
    func login(email: String, password: String, completion: @escaping ((Bool, String) -> Void))
    func signUp(name: String, email: String, password: String, completion: @escaping ((Bool, String) -> Void))
    func signOut(completion: @escaping ((Bool, String) -> Void))
}
