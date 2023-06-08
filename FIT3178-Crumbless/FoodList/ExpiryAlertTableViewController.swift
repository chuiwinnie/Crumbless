//
//  ExpiryAlertTableViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 24/5/2023.
//

import UIKit

class ExpiryAlertTableViewController: UITableViewController {
    let CELL_EXPIRY_ALERT = "expiryAlertCell"
    
    let expiryAlertTableOptions = ["None", "1 day before", "2 days before", "3 days before", "1 week before", "2 weeks before"]
    var selectedExpiryAlertIndex: Int?
    var selectedExpiryAlertOption: String?
    
    weak var selectExpiryAlertDelegate: SelectExpiryAlertDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable large navigation bar title
        navigationItem.largeTitleDisplayMode = .never
        
        showSelectedOption()
    }
    
    // Initialise selectedExpiryAlertIndex based on the previously selected expiry alert option retrieved from the add new food item page
    func showSelectedOption() {
        switch selectedExpiryAlertOption {
        case expiryAlertTableOptions[0]:
            selectedExpiryAlertIndex = 0
        case expiryAlertTableOptions[1]:
            selectedExpiryAlertIndex = 1
        case expiryAlertTableOptions[2]:
            selectedExpiryAlertIndex = 2
        case expiryAlertTableOptions[3]:
            selectedExpiryAlertIndex = 3
        case expiryAlertTableOptions[4]:
            selectedExpiryAlertIndex = 4
        case expiryAlertTableOptions[5]:
            selectedExpiryAlertIndex = 5
        default:
            selectedExpiryAlertIndex = 0
        }
    }
    
    // Dimiss date picker from expiry date field if it is not already dismissed
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expiryAlertTableOptions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure an expiry alert cell
        let expiryAlertCell = tableView.dequeueReusableCell(withIdentifier: CELL_EXPIRY_ALERT, for: indexPath)
        var content = expiryAlertCell.defaultContentConfiguration()
        
        let alert = expiryAlertTableOptions[indexPath.row]
        content.text = alert
        
        // Only add checkmark to the selected expiry alert option
        if(indexPath.row == selectedExpiryAlertIndex) {
            expiryAlertCell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            expiryAlertCell.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        expiryAlertCell.contentConfiguration = content
        return expiryAlertCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Update selectedExpiryAlertIndex and checkmark based on selected alert option
        selectedExpiryAlertIndex = indexPath.row
        tableView.reloadData()
        
        // Inform the add new food item page of the newly selected expiry alert and navigate back
        selectExpiryAlertDelegate?.selectedExpiryAlertOption = expiryAlertTableOptions[selectedExpiryAlertIndex ?? 0]
        navigationController?.popViewController(animated: true)
    }
    
}


/**
 References
 - Showing checkmark for only 1 row: https://stackoverflow.com/questions/10192908/uitableview-checkmark-only-one-row-at-a-time
 */
