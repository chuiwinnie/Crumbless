//
//  FoodListTableViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 26/4/2023.
//

import UIKit

class FoodListTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    let SECTION_FOOD = 0
    let SECTION_INFO = 1
    
    let CELL_FOOD = "foodCell"
    let CELL_INFO = "foodNumberCell"
    
    var foodList: [Food] = []
    var filteredFoodList: [Food] = []
    
    var listenerType = ListenerType.foodItems
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
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
    
    func onFoodItemsChange(change: DatabaseChange, foodItems: [Food]) {
        foodList = foodItems
        updateSearchResults(for: navigationItem.searchController!)
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
            // Configure and return a food cell
            let foodCell = tableView.dequeueReusableCell(withIdentifier: CELL_FOOD, for: indexPath)
            var content = foodCell.defaultContentConfiguration()
            
            let food = filteredFoodList[indexPath.row]
            content.text = food.name
            
            let expiryDate = food.expiryDate
            content.secondaryText = formatDate(date: expiryDate ?? Date())
            
            foodCell.contentConfiguration = content
            return foodCell
        } else {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            var content = infoCell.defaultContentConfiguration()
            
            if foodList.isEmpty {
                content.text = "No items in the list. Tap + to add new items."
            } else {
                content.text = "Total number of item(s): \(filteredFoodList.count)"
            }
            
            infoCell.contentConfiguration = content
            return infoCell
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_FOOD {
            return true
        } else {
            return false
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_FOOD {
            let food = filteredFoodList[indexPath.row]
            databaseController?.deleteFood(food: food)
        }
    }
    
    
    // MARK: - Search Bar
    
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.isActive {
            filteredFoodList = foodList
            tableView.reloadData()
            return
        }
        
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        if searchText.count > 0 {
            filteredFoodList = foodList.filter({ (food: Food) -> Bool in
                return (food.name?.lowercased().contains(searchText) ?? false)
            })
        } else {
            filteredFoodList = foodList
        }
        
        tableView.reloadData()
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFoodDetailsSegue" {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                let destination = segue.destination as! FoodDetailsViewController
                destination.food = filteredFoodList[indexPath.row]
            }
        }
    }
    
}
