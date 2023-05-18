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
    var consumedFoodList: [Food]
    var expiredFoodList: [Food]
    
    var listeners = MulticastDelegate<DatabaseListener>()
    
    // Reference to Firebase Authentication System, Firebase Firestore Database, foodItems, consumedFoodItems & expiredFoodItems collections, current user
    var authController: Auth
    var database: Firestore
    var foodItemsRef: CollectionReference?
    var consumedFoodItemsRef: CollectionReference?
    var expiredFoodItemsRef: CollectionReference?
    var usersRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    
    // Configure each of Firebase frameworks & set up foodList, consumedFoodList and expiredFoodList
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        
        database = Firestore.firestore()
        foodList = [Food]()
        consumedFoodList = [Food]()
        expiredFoodList = [Food]()
        
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
            self.setupConsumedFoodListener()
            self.setupExpiredFoodListener()
        }
    }
    
    
    // MARK: - Add & Remove Listener
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .foodItems {
            listener.onFoodItemsChange(change: .update, foodItems: foodList)
        } else if listener.listenerType == .consumedFoodItems {
            listener.onConsumedFoodItemsChange(change: .update, consumedFoodItems: consumedFoodList)
        } else if listener.listenerType == .expiredFoodItems {
            listener.onExpiredFoodItemsChange(change: .update, expiredFoodItems: expiredFoodList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    // MARK: - Food Items
    
    func addFood(name: String, expiryDate: Date, alert: String) -> Food {
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
    
    
    // MARK: - Consumed Food Items
    
    func addConsumedFood(food: Food) -> Food {
        // Add consumed food to Firestore by using Codable protocol to serialize the data
        do {
            // consumedFoodItemsRef holds a reference to the consumedFoodItems collection in Firebase
            if let consumedFoodRef = try consumedFoodItemsRef?.addDocument(from: food) {
                food.id = consumedFoodRef.documentID
            }
        } catch {
            print("Failed to serialize food")
        }
        
        return food
    }
    
    
    // MARK: - Expired Food Items
    
    func addExpiredFood(food: Food) -> Food {
        // Add expired food to Firestore by using Codable protocol to serialize the data
        do {
            // expiredFoodItemsRef holds a reference to the expiredFoodItems collection in Firebase
            if let expiredFoodRef = try expiredFoodItemsRef?.addDocument(from: food) {
                food.id = expiredFoodRef.documentID
            }
        } catch {
            print("Failed to serialize food")
        }
        
        return food
    }
    
    func cleanup() {}
    
    
    // MARK: - Users
    
    func login(email: String, password: String, completion: @escaping ((Bool, String) -> Void)) {
        Task {
            do {
                let authDataResult = try await authController.signIn(withEmail: email, password: password)
                currentUser = authDataResult.user
                completion(true, "")
                print("User (\(email)) logs in successfully")
            } catch {
                completion(false, "\(error.localizedDescription)")
            }
            self.setupFoodListener()
            self.setupConsumedFoodListener()
            self.setupExpiredFoodListener()
        }
    }
    
    func signUp(email: String, password: String) {
        Task {
            do {
                let authDataResult = try await authController.createUser(withEmail: email, password: password)
                currentUser = authDataResult.user
                addUser()
            }
            catch {
                fatalError("Firebase Authentication Failed with Error\(String(describing: error))")
                //print(error)
            }
            
            self.setupFoodListener()
            self.setupConsumedFoodListener()
            self.setupExpiredFoodListener()
        }
    }
    
    func addUser(){
        do {
            let foodItems: [Food] = []
            let consumedFoodItems: [Food] = []
            let expiredFoodItems: [Food] = []
            
            let user = database.collection("users").document(currentUser!.uid)
            try user.collection("foodItems").document().setData(from: foodItems)
            try user.collection("consumedFoodItems").document().setData(from: consumedFoodItems)
            try user.collection("expiredFoodItems").document().setData(from: expiredFoodItems)
        } catch {
            print("error")
        }
    }
    
    
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
            
            // Decode document's data as Food object using Codable
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
    
    // Called once we have received an authentication result from Firebase
    func setupConsumedFoodListener() {
        // Set up snapshotListener to listen fo all changes on a specified Firestore reference (consumedFoodItems collection)
        consumedFoodItemsRef = database.collection("consumedFoodItems")
        consumedFoodItemsRef?.addSnapshotListener() { (querySnapshot, error) in
            // Execute this closure every time a change is detected on consumedFoodItems collection
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            // Parse changes made on Firestore
            self.parseConsumedFoodItemsSnapshot(snapshot: querySnapshot)
        }
    }
    
    // Parse the snapshot & make any required changes to local properties & call local listeners
    func parseConsumedFoodItemsSnapshot(snapshot: QuerySnapshot) {
        // Go through each document change in the snapshot
        snapshot.documentChanges.forEach { (change) in
            var parsedConsumedFood: Food?
            
            // Decode document's data as Food object using Codable
            do {
                parsedConsumedFood = try change.document.data(as: Food.self)
            } catch {
                print("Unable to decode food. Is the food malformed?")
                return
            }
            
            guard let consumedFood = parsedConsumedFood else {
                print("Document doesn't exist")
                return;
            }
            
            if change.type == .added {
                consumedFoodList.insert(consumedFood, at: Int(change.newIndex))  // Need the order to match Firesotre
            } else if change.type == .modified {
                consumedFoodList[Int(change.oldIndex)] = consumedFood
            } else if change.type == .removed {
                consumedFoodList.remove(at: Int(change.oldIndex))
            }
            
            // Use multicast delegate's invoke method to call onConsumedFoodItemsChange on each listener
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.consumedFoodItems {
                    listener.onConsumedFoodItemsChange(change: .update, consumedFoodItems: consumedFoodList)
                }
            }
        }
    }
    
    // Called once we have received an authentication result from Firebase
    func setupExpiredFoodListener() {
        // Set up snapshotListener to listen fo all changes on a specified Firestore reference (expiredFoodItems collection)
        expiredFoodItemsRef = database.collection("expiredFoodItems")
        expiredFoodItemsRef?.addSnapshotListener() { (querySnapshot, error) in
            // Execute this closure every time a change is detected on expiredFoodItems collection
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            // Parse changes made on Firestore
            self.parseExpiredFoodItemsSnapshot(snapshot: querySnapshot)
        }
    }
    
    // Parse the snapshot & make any required changes to local properties & call local listeners
    func parseExpiredFoodItemsSnapshot(snapshot: QuerySnapshot) {
        // Go through each document change in the snapshot
        snapshot.documentChanges.forEach { (change) in
            var parsedExpiredFood: Food?
            
            // Decode document's data as Food object using Codable
            do {
                parsedExpiredFood = try change.document.data(as: Food.self)
            } catch {
                print("Unable to decode food. Is the food malformed?")
                return
            }
            
            guard let expiredFood = parsedExpiredFood else {
                print("Document doesn't exist")
                return;
            }
            
            if change.type == .added {
                expiredFoodList.insert(expiredFood, at: Int(change.newIndex))  // Need the order to match Firesotre
            } else if change.type == .modified {
                expiredFoodList[Int(change.oldIndex)] = expiredFood
            } else if change.type == .removed {
                expiredFoodList.remove(at: Int(change.oldIndex))
            }
            
            // Use multicast delegate's invoke method to call onExpiredFoodItemsChange on each listener
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.consumedFoodItems {
                    listener.onExpiredFoodItemsChange(change: .update, expiredFoodItems: expiredFoodList)
                }
            }
        }
    }
    
    func setupUsersListener(){
        // Set up snapshotListener to listen fo all changes on a specified Firestore reference (expiredFoodItems collection)
        expiredFoodItemsRef = database.collection("expiredFoodItems")
        expiredFoodItemsRef?.addSnapshotListener() { (querySnapshot, error) in
            // Execute this closure every time a change is detected on expiredFoodItems collection
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            // Parse changes made on Firestore
            self.parseExpiredFoodItemsSnapshot(snapshot: querySnapshot)
        }
        
        // Set up snapshotListener to listen fo all changes on a specified Firestore reference (users collection)
        usersRef = database.collection("users")
        usersRef?.addSnapshotListener() { (querySnapshot, error) in
            // Execute this closure every time a change is detected on users collection
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            // Parse changes made on Firestore
            self.parseFoodItemsSnapshot(snapshot: querySnapshot)
            self.parseExpiredFoodItemsSnapshot(snapshot: querySnapshot)
            self.parseConsumedFoodItemsSnapshot(snapshot: querySnapshot)
            
            if self.usersRef == nil {
                self.setupUsersListener()
            }
        }
    }
    
}
