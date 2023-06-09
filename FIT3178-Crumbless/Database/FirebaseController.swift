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
    
    // Reference to Firebase Authentication System and Firebase Firestore Database
    var authController: Auth
    var database: Firestore
    
    // References to foodItems, consumedFoodItems and expiredFoodItems collections
    var foodItemsRef: CollectionReference?
    var consumedFoodItemsRef: CollectionReference?
    var expiredFoodItemsRef: CollectionReference?
    
    // References to users collections and current user
    var usersRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    
    // Keep track of if/which an existing user is currently signed in
    var user: User?
    var userDefaults: UserDefaults?
    var userSignedIn: Bool?
    
    // Configure each of Firebase frameworks
    override init() {
        // Configure Firebase
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        
        // Set up food list, consumed food list and expired food list
        foodList = [Food]()
        consumedFoodList = [Food]()
        expiredFoodList = [Food]()
        
        // Set up user defaults and check if user signed in
        userDefaults = UserDefaults.standard
        userSignedIn = userDefaults?.bool(forKey: "userSignedIn")
        
        super.init()
        
        // Authenticate with Firebase to read/write to database
        Task {
            do {
                if userSignedIn ?? false {
                    // Set up curent user if already signed in
                    currentUser = authController.currentUser
                    await updateUser()
                    print("User (\(user?.email ?? "NA")) is signed in")
                } else {
                    // Sign in anonymously if not signed in
                    let authDataResult = try await authController.signInAnonymously()
                    currentUser = authDataResult.user
                    print("Signed in anonymously")
                }
            }
            catch {
                fatalError("Firebase Authentication Failed with Error\(String(describing: error))")
            }
            
            // Set up user, food list, consumed food list and expired food list
            self.setupUsersListener()
            self.setupFoodListener()
            self.setupConsumedFoodListener()
            self.setupExpiredFoodListener()
            
        }
    }
    
    func cleanup() {}
    
    
    // MARK: - Listeners
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .foodItems {
            listener.onFoodItemsChange(change: .update, foodItems: foodList)
        } else if listener.listenerType == .consumedOrExpiredFoodItems {
            listener.onConsumedFoodItemsChange(change: .update, consumedFoodItems: consumedFoodList)
            listener.onExpiredFoodItemsChange(change: .update, expiredFoodItems: expiredFoodList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    // MARK: - Food Items
    
    // Add new food to food list
    func addFood(name: String, expiryDate: Date, alert: String, alertTime: String) -> Food {
        let food = Food()
        food.name = name
        food.expiryDate = expiryDate
        food.alert = alert
        food.alertTime = alertTime
        
        // Add created food to foodItems collection
        do {
            // Use Codable protocol to serialise data
            if let foodRef = try foodItemsRef?.addDocument(from: food) {
                food.id = foodRef.documentID
            }
        } catch {
            print("Failed to serialize food")
        }
        
        return food
    }
    
    // Add existing food to new user food list
    func addFood(food: Food) -> Food {
        // Add food to foodItems collection
        do {
            // Use Codable protocol to serialise data
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
    
    func getFoodList() -> [Food] {
        return foodList
    }
    
    func getFoodById(_ id: String) -> Food? {
        for food in foodList {
            if food.id == id {
                return food
            }
        }
        return nil
    }
    
    
    // MARK: - Consumed Food Items
    
    func addConsumedFood(food: Food) -> Food {
        // Add consumed food to consumedFoodItems collection
        do {
            // Use Codable protocol to serialise data
            if let consumedFoodRef = try consumedFoodItemsRef?.addDocument(from: food) {
                food.id = consumedFoodRef.documentID
            }
        } catch {
            print("Failed to serialize consumed food")
        }
        
        return food
    }
    
    
    // MARK: - Expired Food Items
    
    func addExpiredFood(food: Food) -> Food {
        // Add expired food to expiredFoodItems collection
        do {
            // Use Codable protocol to serialise data
            if let expiredFoodRef = try expiredFoodItemsRef?.addDocument(from: food) {
                food.id = expiredFoodRef.documentID
            }
        } catch {
            print("Failed to serialize expired food")
        }
        
        return food
    }
    
    
    // MARK: - Users
    
    func login(email: String, password: String, completion: @escaping ((Bool, String) -> Void)) {
        Task {
            do {
                // Login and update current user
                let authDataResult = try await authController.signIn(withEmail: email, password: password)
                currentUser = authDataResult.user
                
                // Update user login status
                await updateUser()
                userDefaults?.set(true, forKey: "userSignedIn")
                userSignedIn = userDefaults?.bool(forKey: "userSignedIn")
                
                // Reset food list, consumed food list and expired food list
                foodList = []
                consumedFoodList = []
                expiredFoodList = []
                
                // Return login success
                completion(true, "")
                print("User (\(user?.email ?? "NA")) logged in successfully")
            } catch {
                // Return login error
                completion(false, "\(error.localizedDescription)")
            }
            
            self.setupFoodListener()
            self.setupConsumedFoodListener()
            self.setupExpiredFoodListener()
        }
    }
    
    func signUp(name: String, email: String, password: String, completion: @escaping ((Bool, String) -> Void)) {
        Task {
            do {
                // Sign up and update current user
                let authDataResult = try await authController.createUser(withEmail: email, password: password)
                currentUser = authDataResult.user
                
                // Update Firestore collection references
                updateRefs()
                
                // Add new user to users collection
                addUser(name: name, email: email)
                
                // Update user login status
                await updateUser()
                userDefaults?.set(true, forKey: "userSignedIn")
                userSignedIn =  userDefaults?.bool(forKey: "userSignedIn")
                
                // Return sign up success
                completion(true, "")
                print("User (\(user?.email ?? "NA")) signed up successfully")
            }
            catch {
                // Return sign up error
                completion(false, "\(error.localizedDescription)")
            }
            
            self.setupFoodListener()
            self.setupConsumedFoodListener()
            self.setupExpiredFoodListener()
        }
    }
    
    // Update Firestore foodItems, consumedFoodItems and expiredFoodItems references
    func updateRefs() {
        foodItemsRef = usersRef?.document(currentUser!.uid).collection("foodItems")
        consumedFoodItemsRef = usersRef?.document(currentUser!.uid).collection("consumedFoodItems")
        expiredFoodItemsRef = usersRef?.document(currentUser!.uid).collection("expiredFoodItems")
    }
    
    func addUser(name: String, email: String) {
        // Add new user to users collection
        usersRef?.document(currentUser!.uid).setData([
            "name": name,
            "email": email,
        ]) { error in
            if let error = error {
                print("Failed to serialize user: \(error)")
            }
        }
        
        // Transfer food list to new user account food list
        let tempFoodList = foodList
        foodList = []
        for food in tempFoodList {
            let _ = self.addFood(food: food)
        }
        
        // Transfer consumed food list to new user account consumed food list
        let tempConsumedFoodList = consumedFoodList
        consumedFoodList = []
        for consumedFood in tempConsumedFoodList {
            let _ = self.addConsumedFood(food: consumedFood)
        }
        
        // Transfer expired food list to new user acccount expired food list
        let tempExpiredFoodList = expiredFoodList
        expiredFoodList = []
        for expiredFood in tempExpiredFoodList {
            let _ = self.addExpiredFood(food: expiredFood)
        }
    }
    
    func signOut(completion: @escaping ((Bool, String) -> Void)) {
        Task {
            do {
                // Sign out
                try authController.signOut()
                
                // Sign in anonymously and update current user
                let authDataResult = try await authController.signInAnonymously()
                currentUser = authDataResult.user
                
                // Update user login status
                user = nil
                userDefaults?.set(false, forKey: "userSignedIn")
                userSignedIn =  userDefaults?.bool(forKey: "userSignedIn")
                
                // Reset food list, consumed food list and expired food list
                foodList = []
                consumedFoodList = []
                expiredFoodList = []
                
                // Return sign out success
                completion(true, "")
                print("User signed out successfully")
            }
            catch {
                // Return sign out error
                completion(false, "\(error.localizedDescription)")
            }
            
            self.setupFoodListener()
            self.setupConsumedFoodListener()
            self.setupExpiredFoodListener()
        }
    }
    
    // Update user of the app
    func updateUser() async {
        do {
            user = try await database.collection("users").document(currentUser!.uid).getDocument(as: User.self)
        } catch {
            print("Unable to decode user. Is the user malformed?")
        }
    }
    
    
    // MARK: - Set Up Food List
    
    func setupFoodListener() {
        // Get reference to current user foodItems collection
        foodItemsRef = usersRef?.document(currentUser!.uid).collection("foodItems")
        
        // Set up snapshotListener to listen fo all changes on a foodItems collection
        foodItemsRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch food documents with error: \(String(describing: error))")
                return
            }
            
            // Parse changes made on Firestore
            self.parseFoodItemsSnapshot(snapshot: querySnapshot)
        }
    }
    
    // Parse the snapshot and make any required changes to local food list
    func parseFoodItemsSnapshot(snapshot: QuerySnapshot) {
        // Go through each document change in the snapshot
        snapshot.documentChanges.forEach { (change) in
            var parsedFood: Food?
            
            // Decode document data as Food object using Codable
            do {
                parsedFood = try change.document.data(as: Food.self)
            } catch {
                print("Unable to decode food. Is the food malformed?")
                return
            }
            
            guard let food = parsedFood else {
                print("Food document doesn't exist")
                return;
            }
            
            // Update food list
            if change.type == .added {
                foodList.insert(food, at: Int(change.newIndex))
            } else if change.type == .modified {
                foodList[Int(change.oldIndex)] = food
            } else if change.type == .removed {
                foodList.remove(at: Int(change.oldIndex))
            }
            
            // Use multicast delegate invoke method to call onFoodItemsChange on each listener
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.foodItems {
                    listener.onFoodItemsChange(change: .update, foodItems: foodList)
                }
            }
        }
    }
    
    
    // MARK: - Set Up Consumed Food List
    
    // Called once we have received an authentication result from Firebase
    func setupConsumedFoodListener() {
        // Get reference to current user consumedFoodItems collection
        consumedFoodItemsRef = usersRef?.document(currentUser!.uid).collection("consumedFoodItems")
        
        // Set up snapshotListener to listen fo all changes on consumedFoodItems collection
        consumedFoodItemsRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch consumed food documents with error: \(String(describing: error))")
                return
            }
            
            // Parse changes made on Firestore
            self.parseConsumedFoodItemsSnapshot(snapshot: querySnapshot)
        }
    }
    
    // Parse the snapshot and make any required changes to local consumed food list
    func parseConsumedFoodItemsSnapshot(snapshot: QuerySnapshot) {
        // Go through each document change in the snapshot
        snapshot.documentChanges.forEach { (change) in
            var parsedConsumedFood: Food?
            
            // Decode document data as Food object using Codable
            do {
                parsedConsumedFood = try change.document.data(as: Food.self)
            } catch {
                print("Unable to decode consumed food. Is the food malformed?")
                return
            }
            
            guard let consumedFood = parsedConsumedFood else {
                print("Consumed food document doesn't exist")
                return;
            }
            
            // Update consumed food list
            if change.type == .added {
                consumedFoodList.insert(consumedFood, at: Int(change.newIndex))  // Need the order to match Firesotre
            } else if change.type == .modified {
                consumedFoodList[Int(change.oldIndex)] = consumedFood
            } else if change.type == .removed {
                consumedFoodList.remove(at: Int(change.oldIndex))
            }
            
            // Use multicast delegate invoke method to call onConsumedFoodItemsChange on each listener
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.consumedOrExpiredFoodItems {
                    listener.onConsumedFoodItemsChange(change: .update, consumedFoodItems: consumedFoodList)
                }
            }
        }
    }
    
    
    // MARK: - Set Up Expired Food List
    
    // Called once we have received an authentication result from Firebase
    func setupExpiredFoodListener() {
        // Get reference to current user expiredFoodItems collection
        expiredFoodItemsRef = usersRef?.document(currentUser!.uid).collection("expiredFoodItems")
        
        // Set up snapshotListener to listen fo all changes on expiredFoodItems collection
        expiredFoodItemsRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch expired food documents with error: \(String(describing: error))")
                return
            }
            
            // Parse changes made on Firestore
            self.parseExpiredFoodItemsSnapshot(snapshot: querySnapshot)
        }
    }
    
    // Parse the snapshot and make any required changes to local expired food list
    func parseExpiredFoodItemsSnapshot(snapshot: QuerySnapshot) {
        // Go through each document change in the snapshot
        snapshot.documentChanges.forEach { (change) in
            var parsedExpiredFood: Food?
            
            // Decode document data as Food object using Codable
            do {
                parsedExpiredFood = try change.document.data(as: Food.self)
            } catch {
                print("Unable to decode expired food. Is the food malformed?")
                return
            }
            
            guard let expiredFood = parsedExpiredFood else {
                print("Expired food document doesn't exist")
                return;
            }
            
            // Update expired food list
            if change.type == .added {
                expiredFoodList.insert(expiredFood, at: Int(change.newIndex))  // Need the order to match Firesotre
            } else if change.type == .modified {
                expiredFoodList[Int(change.oldIndex)] = expiredFood
            } else if change.type == .removed {
                expiredFoodList.remove(at: Int(change.oldIndex))
            }
            
            // Use multicast delegate invoke method to call onExpiredFoodItemsChange on each listener
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.consumedOrExpiredFoodItems {
                    listener.onExpiredFoodItemsChange(change: .update, expiredFoodItems: expiredFoodList)
                }
            }
        }
    }
    
    
    // MARK: - Set Up Users
    
    func setupUsersListener(){
        // Get reference to users collection
        usersRef = database.collection("users")
        
        // Set up snapshotListener to listen fo all changes on users collection
        usersRef?.addSnapshotListener() { (querySnapshot, error) in
            guard querySnapshot != nil else {
                print("Failed to fetch user documents with error: \(String(describing: error))")
                return
            }
            if self.usersRef == nil {
                self.setupUsersListener()
            }
        }
    }
    
}


/**
 References
 - Getting returned values from async login and signup functions: https://stackoverflow.com/questions/52287840/how-i-can-return-value-from-async-block-in-swift
 - Adding users to Firestore: https://firebase.google.com/docs/firestore/manage-data/add-data
 */
