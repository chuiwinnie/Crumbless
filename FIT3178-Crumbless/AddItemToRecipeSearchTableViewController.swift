//
//  AddItemToRecipeSearchTableViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 3/5/2023.
//

import UIKit

class AddItemToRecipeSearchTableViewController: UITableViewController {
    let SECTION_FOOD = 0
    let SECTION_INFO = 1
    
    let CELL_FOOD = "foodCell"
    let CELL_INFO = "foodNumberCell"
    
    var foodList: [Food] = []
    var filteredFoodList: [Food] = []
    
    weak var addItemToRecipeSearchDelegate: AddNewFoodItemDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        addDefaultFood()
        filteredFoodList = foodList
    }

    
    func addDefaultFood() {
        foodList.append(Food(name: "bread", expiryDate: Date()))
        foodList.append(Food(name: "eggs", expiryDate: Date()))
        foodList.append(Food(name: "broccoli", expiryDate: Date()))
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
            
            let food = foodList[indexPath.row]
            content.text = food.name
            
            let expiryDate = food.expiryDate
            content.secondaryText = formatDate(date: expiryDate)
            
            foodCell.contentConfiguration = content
            return foodCell
        } else {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            var content = infoCell.defaultContentConfiguration()
            
            if foodList.isEmpty {
                content.text = "No items in the food item list."
            } else {
                content.text = "Total number of item(s): \(filteredFoodList.count)"
            }
            
            infoCell.contentConfiguration = content
            return infoCell
        }
    }
    
    // Override to support selecting a row within the table view.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SECTION_INFO {
            return
        }
        
        if let addItemToRecipeSearchDelegate = addItemToRecipeSearchDelegate {
            let itemAdded = addItemToRecipeSearchDelegate.addFood(filteredFoodList[indexPath.row])
            
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
    }
    */

}
