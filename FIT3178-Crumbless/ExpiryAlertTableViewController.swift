//
//  ExpiryAlertTableViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 24/5/2023.
//

import UIKit

class ExpiryAlertTableViewController: UITableViewController {
    let CELL_EXPIRY_ALERT = "expiryAlertCell"
    
    var alertOptions = ["None", "1 day before", "2 days before", "3 days before", "1 week before", "2 weeks before" ]
    var selectedIndex: Int = 0
    var selectedExpiryAlert: String?
    
    weak var selectExpiryAlertDelegate: SelectExpiryAlertDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showSelectedOption()
    }
    
    func showSelectedOption() {
        switch selectedExpiryAlert {
        case alertOptions[0]:
            selectedIndex = 0
        case alertOptions[1]:
            selectedIndex = 1
        case alertOptions[2]:
            selectedIndex = 2
        case alertOptions[3]:
            selectedIndex = 3
        case alertOptions[4]:
            selectedIndex = 4
        case alertOptions[5]:
            selectedIndex = 5
        default:
            selectedIndex = 0
        }
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertOptions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure and return a expiry alert cell
        let expiryAlertCell = tableView.dequeueReusableCell(withIdentifier: CELL_EXPIRY_ALERT, for: indexPath)
        var content = expiryAlertCell.defaultContentConfiguration()
        
        let alert = alertOptions[indexPath.row]
        content.text = alert
        
        if(indexPath.row == selectedIndex)
        {
            expiryAlertCell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        else
        {
            expiryAlertCell.accessoryType =  UITableViewCell.AccessoryType.none
        }
        
        expiryAlertCell.contentConfiguration = content
        return expiryAlertCell
    }
    
    // Override to support selecting a row within the table view.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
        
        selectExpiryAlertDelegate?.selectedExpiryAlertOption = alertOptions[selectedIndex]
        navigationController?.popViewController(animated: true)
    }
        
}
