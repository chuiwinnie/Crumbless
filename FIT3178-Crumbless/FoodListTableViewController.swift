//
//  FoodListTableViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 26/4/2023.
//

import UIKit

class FoodListTableViewController: UITableViewController {
    
    let SECTION_FOOD = 0
    let SECTION_INFO = 1
    
    let CELL_FOOD = "heroFood"
    let CELL_INFO = "foodNumberCell"
    
    var foodList: [Food] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
            
            if let expiryDate = food.expiryDate {
                content.secondaryText = formatDate(date: expiryDate)
            }
            
            foodCell.contentConfiguration = content
            return foodCell
        } else {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            var content = infoCell.defaultContentConfiguration()
            
            if foodList.isEmpty {
            content.text = "No items in the list. Tap + to add new items."
            } else {
            content.text = "Total number of item(s): \(foodList.count)"
            }
            
            infoCell.contentConfiguration = content
            return infoCell
        }
    }
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        return dateFormatter.string(from: date)
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_FOOD {
            return true
        } else {
            return false
        }
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
     */
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_FOOD {
            tableView.performBatchUpdates({
                self.foodList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.reloadSections([SECTION_INFO], with: .automatic)
            }, completion: nil)
        }
    }


    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
