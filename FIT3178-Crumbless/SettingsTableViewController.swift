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
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
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
            if databaseController?.userSignedIn ?? false {
                content.secondaryText = databaseController?.user?.name
            } else {
                content.secondaryText = "Not logged in"
            }
            
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
}
