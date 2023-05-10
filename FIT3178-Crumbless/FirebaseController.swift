//
//  FirebaseController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 10/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    var foodList: [Food]
    
    var listeners = MulticastDelegate<DatabaseListener>()
    
    // Reference to Firebase Authentication System, Firebase Firestore Database, heroes & teams collections, current user
    var authController: Auth
    var database: Firestore
    var foodItemsRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    
    // Configure each of Firebase frameworks & set up heroList & defaultTeam
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        
        database = Firestore.firestore()
        foodList = [Food]()
        
        super.init()
        
        // Authenticate with Firebase to read/write to database by signing in anonymously
        Task {
            do {
                let authDataResult = try await authController.signInAnonymously()
                currentUser = authDataResult.user  // Set currentUser as fetched user info
            }
            catch {
                fatalError("Firebase Authentication Failed with Error\(String(describing: error))")
            }
            self.setupFoodListener()
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .foodItems {
            listener.onFoodItemsChange(change: .update, foodItems: foodList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addFood(name: String, expiryDate: Date, alert: String) -> Food {
        print("called")
        let food = Food()
        food.name = name
        food.expiryDate = expiryDate
        food.alert = alert
        
        // Add created food to Firestore by using Codable protocol to serialize the data
        do {
            // foodItemsRef holds a reference to the foodItems collection in Firebase
            if let foodRef = try foodItemsRef?.addDocument(from: food) {
                food.id = foodRef.documentID
            }
        } catch {
            print("Failed to serialize food")
        }
        
        return food
    }
    
    func updateFood(food: Food) {
        if let foodId = food.id {
            do {
                try foodItemsRef?.document(foodId).setData(from: food)
            }
            catch {
                print(error)
            }
        }
    }
    
    func deleteFood(food: Food) {
        if let foodId = food.id {
            foodItemsRef?.document(foodId).delete()
        }
    }
    
    func cleanup() {}
    
    
    // MARK: - Firebase Controller Specific Methods
    
    func getFoodById(_ id: String) -> Food? {
        for food in foodList {
            if food.id == id {
                return food
            }
        }
        return nil
    }
    
    // Called once we have received an authentication result from Firebase
    func setupFoodListener() {
        // Set up snapshotListener to listen fo all changes on a specified Firestore reference (foodItems collection)
        foodItemsRef = database.collection("foodItems")
        foodItemsRef?.addSnapshotListener() { (querySnapshot, error) in
            // Execute this closure every time a change is detected on foodItems collection
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            // Parse changes made on Firestore
            self.parseFoodItemsSnapshot(snapshot: querySnapshot)
        }
    }
    
    // Parse the snapshot & make any required changes to local properties & call local listeners
    func parseFoodItemsSnapshot(snapshot: QuerySnapshot) {
        // Go through each document change in the snapshot
        snapshot.documentChanges.forEach { (change) in
            var parsedFood: Food?
            
            // Decode document's data as Superhero object using Codable
            do {
                parsedFood = try change.document.data(as: Food.self)
            } catch {
                print("Unable to decode food. Is the food malformed?")
                return
            }
            
            guard let food = parsedFood else {
                print("Document doesn't exist")
                return;
            }
            
            if change.type == .added {
                foodList.insert(food, at: Int(change.newIndex))  // Need the order to match Firesotre
            } else if change.type == .modified {
                foodList[Int(change.oldIndex)] = food
            } else if change.type == .removed {
                foodList.remove(at: Int(change.oldIndex))
            }
            
            // Use multicast delegate's invoke method to call onFoodItemsChange on each listener
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.foodItems {
                    listener.onFoodItemsChange(change: .update, foodItems: foodList)
                }
            }
        }
    }
    
}
