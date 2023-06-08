//
//  AddItemToRecipeSearchTableViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 3/5/2023.
//

import UIKit

class AddItemToRecipeSearchTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    let SECTION_FOOD = 0
    let SECTION_INFO = 1
    
    let CELL_FOOD = "foodCell"
    let CELL_INFO = "foodNumberCell"
    
    var listenerType = ListenerType.foodItems
    weak var databaseController: DatabaseProtocol?
    
    weak var addToRecipeSearchDelegate: AddToRecipeSearchDelegate?
    
    var foodList: [Food] = []
    var filteredFoodList: [Food] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Copy food list to filtered food list for searching
        filteredFoodList = foodList
        
        // Set up search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search All Food Items"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    // MARK: - Database
    
    func onFoodItemsChange(change: DatabaseChange, foodItems: [Food]) {
        foodList = foodItems
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    func onConsumedFoodItemsChange(change: DatabaseChange, consumedFoodItems: [Food]) {
        // Consumed food items are not shown in this tab/table, hence do nothing
    }
    
    func onExpiredFoodItemsChange(change: DatabaseChange, expiredFoodItems: [Food]) {
        // Expired food items are not shown in this tab/table, hence do nothing
    }
    
    func onUsersChange(change: DatabaseChange, users: [User]) {
        // Users are not show in tab/table, hence do nothing
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case SECTION_FOOD:
            return filteredFoodList.count
        case SECTION_INFO:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_FOOD {
            // Configure a food cell
            let foodCell = tableView.dequeueReusableCell(withIdentifier: CELL_FOOD, for: indexPath)
            var content = foodCell.defaultContentConfiguration()
            
            // Set the text of each cell as the food name
            let food = filteredFoodList[indexPath.row]
            content.text = food.name
            
            // Set the secondary text of each cell as the expiry date
            let expiryDate = food.expiryDate
            content.secondaryText = dateToString(date: expiryDate ?? Date())
            
            // Set the accessory view of each cell as the number of days left before the expiry date
            let accessoryView = getFoodCellAccessoryView(expiryDate: expiryDate ?? Date())
            
            foodCell.contentConfiguration = content
            foodCell.accessoryView = accessoryView
            return foodCell
        } else {
            // Configure an info cell
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            var content = infoCell.defaultContentConfiguration()
            
            // Indicate how many food items are in the food list, if any
            if foodList.isEmpty {
                content.text = "No items in the food item list."
            } else {
                content.text = "Total number of item(s): \(filteredFoodList.count)"
            }
            
            infoCell.contentConfiguration = content
            return infoCell
        }
    }
    
    // Create and return the accessory view to attach to each food cell
    func getFoodCellAccessoryView(expiryDate: Date) -> UIView {
        // Calculate the number of days before food expiry
        let remainingDays = getDaysBeforeExpiry(expiryDate: expiryDate)
        
        // Create label for remaining number of days
        let remainingDaysLabel = UILabel.init(frame: CGRect(x:0, y:0, width:80, height:20))
        remainingDaysLabel.text = String(remainingDays)
        if remainingDays == 0 {
            remainingDaysLabel.text = "Today"
        } else if remainingDays == 1 {
            remainingDaysLabel.text! += " Day"
        } else {
            remainingDaysLabel.text! += " Days"
        }
        remainingDaysLabel.textAlignment = .right
        
        // Create accessory view for food cell
        let accessoryView = UIStackView.init(frame: CGRect(x:0, y:0, width:100, height:20))
        accessoryView.addArrangedSubview(remainingDaysLabel)
        
        return accessoryView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Make info cell non-selectable
        if indexPath.section == SECTION_INFO {
            return
        }
        
        // Add the food to recipe search if its cell is selected
        if let addItemToRecipeSearchDelegate = addToRecipeSearchDelegate {
            let itemAdded = addItemToRecipeSearchDelegate.addFood(filteredFoodList[indexPath.row])
            
            // Remove food from list once added to recipe search
            if itemAdded {
                if let index = foodList.firstIndex(of: filteredFoodList[indexPath.row]) {
                    self.foodList.remove(at: index)
                }
                filteredFoodList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.reloadSections([SECTION_INFO], with: .automatic)
                
                navigationController?.popViewController(animated: false)
                return
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Search Bar
    
    // Update search results based on entered search text
    func updateSearchResults(for searchController: UISearchController) {
        // Reset filtered food list once cancelled searching
        if !searchController.isActive {
            filteredFoodList = foodList
            tableView.reloadData()
            return
        }
        
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        if searchText.count > 0 {
            // Show only food items with name that matches the entered search text
            filteredFoodList = foodList.filter({ (food: Food) -> Bool in
                return (food.name?.lowercased().contains(searchText) ?? false)
            })
        } else {
            // Show all food items if no search text entered
            filteredFoodList = foodList
        }
        
        tableView.reloadData()
    }
    
}


/**
 References
 - Adding number of days before food expiry to the right of each food cell: https://stackoverflow.com/questions/49473959/ios-swift-uitableviewcell-with-left-detail-and-right-detail-and-subtitle
 - Right aligning text for number of days before food expiry: https://stackoverflow.com/questions/24034300/swift-uilabel-text-alignment
 - Creating stack view for food cell accessory view: https://www.kodeco.com/2198310-uistackview-tutorial-for-ios-introducing-stack-views#toc-anchor-011
 */
