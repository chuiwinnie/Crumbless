//
//  SettingsTableViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 17/5/2023.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    let SECTION_ACCOUNT = 0
    let SECTION_DARK_MODE = 1
    let SECTION_DATE_FORMAT = 2
    
    let CELL_ACCOUNT = "accountCell"
    let CELL_DARK_MODE = "darkModeCell"
    let CELL_DATE_FORMAT = "dateFormatCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_ACCOUNT {
            // Configure and return an account cell
            let accountCell = tableView.dequeueReusableCell(withIdentifier: CELL_ACCOUNT, for: indexPath)
            
            var content = accountCell.defaultContentConfiguration()
            content.text = "Account"
            content.secondaryText = "Not logged in"
            
            accountCell.contentConfiguration = content
            return accountCell
        } else if indexPath.section == SECTION_DARK_MODE {
            let darkModeCell = tableView.dequeueReusableCell(withIdentifier: CELL_DARK_MODE, for: indexPath)
            
            var content = darkModeCell.defaultContentConfiguration()
            content.text = "Dark Mode"
            
            darkModeCell.contentConfiguration = content
            return darkModeCell
        } else {
            let dateFormatCell = tableView.dequeueReusableCell(withIdentifier: CELL_DATE_FORMAT, for: indexPath)
            
            var content = dateFormatCell.defaultContentConfiguration()
            content.text = "Date Format"
            content.secondaryText = "DD-MM-YYYY"
            
            dateFormatCell.contentConfiguration = content
            return dateFormatCell
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
