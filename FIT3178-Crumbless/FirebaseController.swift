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
    
    // Keep track of if/which an existing user is currently signed in
    var user: User?
    var userDefaults: UserDefaults?
    var userSignedIn: Bool?
    
    // Configure each of Firebase frameworks & set up foodList, consumedFoodList and expiredFoodList
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        foodList = [Food]()
        consumedFoodList = [Food]()
        expiredFoodList = [Food]()
        
        userDefaults = UserDefaults.standard
        userSignedIn = userDefaults?.bool(forKey: "userSignedIn")
        
        super.init()
        
        // Authenticate with Firebase to read/write to database by signing in anonymously
        Task {
            do {
                if userSignedIn ?? false {
                    currentUser = authController.currentUser
                    await getUser()
                    print("User (\(user?.email ?? "NA")) is signed in")
                } else {
                    let authDataResult = try await authController.signInAnonymously()
                    currentUser = authDataResult.user
                    print("Signed in anonymously")
                }
            }
            catch {
                fatalError("Firebase Authentication Failed with Error\(String(describing: error))")
            }
            
            self.setupUsersListener()
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
        } else if listener.listenerType == .consumedOrExpiredFoodItems {
            listener.onConsumedFoodItemsChange(change: .update, consumedFoodItems: consumedFoodList)
            listener.onExpiredFoodItemsChange(change: .update, expiredFoodItems: expiredFoodList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    // MARK: - Food Items
    
    func addFood(name: String, expiryDate: Date, alert: String, alertTime: String) -> Food {
        let food = Food()
        food.name = name
        food.expiryDate = expiryDate
        food.alert = alert
        food.alertTime = alertTime
        
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
    
    func addFood(food: Food) -> Food {
        // Add food to Firestore by using Codable protocol to serialize the data
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
            print("Failed to serialize consumed food")
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
            print("Failed to serialize expired food")
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
                
                await getUser()
                userDefaults?.set(true, forKey: "userSignedIn")
                userSignedIn =  userDefaults?.bool(forKey: "userSignedIn")
                
                foodList = []
                consumedFoodList = []
                expiredFoodList = []
                
                completion(true, "")
                print("User (\(user?.email ?? "NA")) logs in successfully")
            } catch {
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
                let authDataResult = try await authController.createUser(withEmail: email, password: password)
                currentUser = authDataResult.user
                
                updateRefs()
                addUser(name: name, email: email)
                
                await getUser()
                userDefaults?.set(true, forKey: "userSignedIn")
                userSignedIn =  userDefaults?.bool(forKey: "userSignedIn")
                
                completion(true, "")
                print("User (\(user?.email ?? "NA")) signs up successfully")
            }
            catch {
                completion(false, "\(error.localizedDescription)")
            }
            
            self.setupFoodListener()
            self.setupConsumedFoodListener()
            self.setupExpiredFoodListener()
        }
    }
    
    func updateRefs() {
        foodItemsRef = usersRef?.document(currentUser!.uid).collection("foodItems")
        consumedFoodItemsRef = usersRef?.document(currentUser!.uid).collection("consumedFoodItems")
        expiredFoodItemsRef = usersRef?.document(currentUser!.uid).collection("expiredFoodItems")
    }
    
    func addUser(name: String, email: String) {
        print("current user uid: " + currentUser!.uid)
        usersRef?.document(currentUser!.uid).setData([
            "name": name,
            "email": email,
        ]) { error in
            if let error = error {
                print("Failed to serialize user: \(error)")
            }
        }
        
        let tempFoodList = foodList
        foodList = []
        for food in tempFoodList {
            let _ = self.addFood(food: food)
        }
        
        let tempConsumedFoodList = consumedFoodList
        consumedFoodList = []
        for consumedFood in tempConsumedFoodList {
            let _ = self.addConsumedFood(food: consumedFood)
        }
        
        let tempExpiredFoodList = expiredFoodList
        expiredFoodList = []
        for expiredFood in tempExpiredFoodList {
            let _ = self.addExpiredFood(food: expiredFood)
        }
    }
    
    func signOut(completion: @escaping ((Bool, String) -> Void)) {
        Task {
            do {
                try authController.signOut()
                                
                let authDataResult = try await authController.signInAnonymously()
                currentUser = authDataResult.user
                
                user = nil
                userDefaults?.set(false, forKey: "userSignedIn")
                userSignedIn =  userDefaults?.bool(forKey: "userSignedIn")
                
                foodList = []
                consumedFoodList = []
                expiredFoodList = []
                
                completion(true, "")
                print("User signs out successfully")
            }
            catch {
                completion(false, "\(error.localizedDescription)")
            }
            
            self.setupFoodListener()
            self.setupConsumedFoodListener()
            self.setupExpiredFoodListener()
        }
    }
    
    func getUser() async {
        do {
            user = try await database.collection("users").document(currentUser!.uid).getDocument(as: User.self)
        } catch {
            print("Unable to decode user. Is the user malformed?")
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
        foodItemsRef = usersRef?.document(currentUser!.uid).collection("foodItems")
        foodItemsRef?.addSnapshotListener() { (querySnapshot, error) in
            // Execute this closure every time a change is detected on foodItems collection
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch food documents with error: \(String(describing: error))")
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
                print("Food document doesn't exist")
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
        consumedFoodItemsRef = usersRef?.document(currentUser!.uid).collection("consumedFoodItems")
        consumedFoodItemsRef?.addSnapshotListener() { (querySnapshot, error) in
            // Execute this closure every time a change is detected on consumedFoodItems collection
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch consumed food documents with error: \(String(describing: error))")
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
                print("Unable to decode consumed food. Is the food malformed?")
                return
            }
            
            guard let consumedFood = parsedConsumedFood else {
                print("Consumed food document doesn't exist")
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
                if listener.listenerType == ListenerType.consumedOrExpiredFoodItems {
                    listener.onConsumedFoodItemsChange(change: .update, consumedFoodItems: consumedFoodList)
                }
            }
        }
    }
    
    // Called once we have received an authentication result from Firebase
    func setupExpiredFoodListener() {
        // Set up snapshotListener to listen fo all changes on a specified Firestore reference (expiredFoodItems collection)
        expiredFoodItemsRef = usersRef?.document(currentUser!.uid).collection("expiredFoodItems")
        expiredFoodItemsRef?.addSnapshotListener() { (querySnapshot, error) in
            // Execute this closure every time a change is detected on expiredFoodItems collection
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch expired food documents with error: \(String(describing: error))")
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
                print("Unable to decode expired food. Is the food malformed?")
                return
            }
            
            guard let expiredFood = parsedExpiredFood else {
                print("Expired food document doesn't exist")
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
                if listener.listenerType == ListenerType.consumedOrExpiredFoodItems {
                    listener.onExpiredFoodItemsChange(change: .update, expiredFoodItems: expiredFoodList)
                }
            }
        }
    }
    
    func setupUsersListener(){
        // Set up snapshotListener to listen fo all changes on a specified Firestore reference (users collection)
        usersRef = database.collection("users")
        usersRef?.addSnapshotListener() { (querySnapshot, error) in
            // Execute this closure every time a change is detected on users collection
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
