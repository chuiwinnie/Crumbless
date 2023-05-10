//
//  RecipeSearchTableViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 26/4/2023.
//

import UIKit

class RecipeSearchTableViewController: UITableViewController, AddNewFoodItemDelegate {
    let SECTION_FOOD = 0
    let SECTION_INFO = 1
    
    let CELL_FOOD = "foodCell"
    let CELL_INFO = "foodNumberCell"
    
    var foodList: [Food] = []
    
    @IBOutlet weak var searchRecipeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateButtonDisplay()
    }
    
    func updateButtonDisplay() {
        if foodList.isEmpty {
            searchRecipeButton.isEnabled = false
        } else {
            searchRecipeButton.isEnabled = true
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case SECTION_FOOD:
            return foodList.count
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
            
            let food = foodList[indexPath.row]
            content.text = food.name
            
            let expiryDate = food.expiryDate
            content.secondaryText = formatDate(date: expiryDate ?? Date())
            
            foodCell.contentConfiguration = content
            return foodCell
        } else {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            var content = infoCell.defaultContentConfiguration()
            
            if foodList.isEmpty {
                content.text = "No food items added to the recipe search.\nTap + to add items to the search."
            } else {
                content.text = "Number of item(s) added to search: \(foodList.count)"
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
            tableView.performBatchUpdates({
                if let index = self.foodList.firstIndex(of: foodList[indexPath.row]) {
                    self.foodList.remove(at: index)
                }
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.reloadSections([SECTION_INFO], with: .automatic)
            }, completion: nil)
        }
        
        updateButtonDisplay()
    }
    
    
    // MARK: - Delegate
    func addFood(_ food: Food) -> Bool {
        tableView.performBatchUpdates({
            // Safe because search can't be active when Add button is tapped.
            foodList.append(food)
            
            tableView.insertRows(at: [IndexPath(row: foodList.count - 1, section: SECTION_FOOD)], with: .automatic)
            
            tableView.reloadSections([SECTION_INFO], with: .automatic)
        }, completion: nil)
        
        updateButtonDisplay()
        
        return true
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItemToRecipeSearchSegue" {
            let destination = segue.destination as! AddItemToRecipeSearchTableViewController
            destination.addItemToRecipeSearchDelegate = self
        } else if segue.identifier == "searchRecipeSegue" {
            let destination = segue.destination as! RecipeSearchResultsTableViewController
            destination.ingredients = foodList
        }
    }
    
}
