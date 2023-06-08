//
//  SettingsTableViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 17/5/2023.
//

import UIKit

class SettingsTableViewController: UITableViewController, SelectDateFormatDelegate {
    let SECTION_ACCOUNT = 0
    let SECTION_DARK_MODE = 1
    let SECTION_DATE_FORMAT = 2
    let SECTION_ABOUT = 3
    
    let CELL_ACCOUNT = "accountCell"
    let CELL_DARK_MODE = "darkModeCell"
    let CELL_DATE_FORMAT = "dateFormatCell"
    let CELL_ABOUT = "aboutCell"
    
    weak var databaseController: DatabaseProtocol?
    
    var userDefaults: UserDefaults?
    
    var selectedDateFormatOption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Set up user defaults
        userDefaults = UserDefaults.standard
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Reload table to display updated user and preferred date format
        tableView.reloadData()
        
        // Retrieve selected preferred date format
        selectedDateFormatOption = userDefaults?.string(forKey: "dateFormat") ?? "DD-MM-YYYY"
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_ACCOUNT {
            // Configure an account cell
            let accountCell = tableView.dequeueReusableCell(withIdentifier: CELL_ACCOUNT, for: indexPath)
            
            var content = accountCell.defaultContentConfiguration()
            content.text = "Account"
            
            // Display user account name if logged in
            if databaseController?.userSignedIn ?? false {
                content.secondaryText = databaseController?.user?.name
            } else {
                content.secondaryText = "Not logged in"
            }
            
            accountCell.contentConfiguration = content
            accountCell.accessoryType = .disclosureIndicator
            return accountCell
        } else if indexPath.section == SECTION_DARK_MODE {
            // Configure a dark mode cell
            let darkModeCell = tableView.dequeueReusableCell(withIdentifier: CELL_DARK_MODE, for: indexPath)
            
            var content = darkModeCell.defaultContentConfiguration()
            content.text = "Dark Mode"
            
            // Attach toggle switch to dark mode cell
            let darkModeSwitch = setUpDarkModeSwitch(indexPathRow: indexPath.row)
            darkModeCell.accessoryView = darkModeSwitch
            
            darkModeCell.contentConfiguration = content
            return darkModeCell
        } else if indexPath.section == SECTION_DATE_FORMAT {
            // Configure a date format cell
            let dateFormatCell = tableView.dequeueReusableCell(withIdentifier: CELL_DATE_FORMAT, for: indexPath)
            
            var content = dateFormatCell.defaultContentConfiguration()
            content.text = "Date Format"
            
            // Set the secondary text as the selected preferred date format
            content.secondaryText = userDefaults?.string(forKey: "dateFormat") ?? "DD-MM-YYYY"
            
            dateFormatCell.contentConfiguration = content
            dateFormatCell.accessoryType = .disclosureIndicator
            return dateFormatCell
        } else {
            // Configure an about cell
            let aboutCell = tableView.dequeueReusableCell(withIdentifier: CELL_ABOUT, for: indexPath)
            
            var content = aboutCell.defaultContentConfiguration()
            content.text = "About"
            
            aboutCell.contentConfiguration = content
            aboutCell.accessoryType = .disclosureIndicator
            return aboutCell
        }
    }
    
    // Create and return a dark mode toggle switch
    func setUpDarkModeSwitch(indexPathRow: Int) -> UISwitch {
        let darkModeSwitch = UISwitch(frame: .zero)
        
        // Set previously selected appearance preference
        let darkModeOn = userDefaults?.bool(forKey: "darkMode") ?? false
        if darkModeOn {
            darkModeSwitch.setOn(true, animated: true)
        } else {
            darkModeSwitch.setOn(false, animated: true)
        }
        
        // Attach toggle switch to dark mode cell
        darkModeSwitch.tag = indexPathRow
        
        // Update appearance preference once toggle switch changed
        darkModeSwitch.addTarget(self, action: #selector(darkModeSwitchChanged(darkModeSwitch: )), for: .valueChanged)
        
        return darkModeSwitch
    }
    
    // Update appearance preference in user defaults
    @objc func darkModeSwitchChanged(darkModeSwitch: UISwitch) {
        if darkModeSwitch.isOn {
            userDefaults?.set(true, forKey: "darkMode")
        } else {
            userDefaults?.set(false, forKey: "darkMode")
        }
        
        // Update display to light or dark mode
        setAppearance()
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Set the previously selected preferred date format before navigating to the date format page
        if segue.identifier == "showDateFormatSegue" {
            let destination = segue.destination as! DateFormatTableViewController
            destination.selectDateFormatDelegate = self
            destination.selectedDateFormatOption = selectedDateFormatOption
        }
    }
    
}


/**
 References
 - Dark mode toggle swtich: https://www.youtube.com/watch?v=JJLJIkN-Da8
 */
