//
//  DateFormatTableViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 7/6/2023.
//

import UIKit

class DateFormatTableViewController: UITableViewController {
    let CELL_DATE_FORMAT = "dateFormatCell"
    
    weak var selectDateFormatDelegate: SelectDateFormatDelegate?
    
    let dateFormatTableOptions = ["dd-MM-yyyy", "MM-dd-yyyy", "yyyy-MM-dd",
                                  "dd/MM/yyyy", "MM/dd/yyyy", "dd/MM/yy", "MM/dd/yy",
                                  "dd MMMM yyyy", "MMMM dd yyyy", "dd MMM yyyy", "MMM dd yyyy"]
    var selectedDateFormatIndex: Int?
    var selectedDateFormatOption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSelectedOption()
    }
    
    // Initialise selectedDateFormatIndex based on the previously selected preferred date format retrieved from the settings page
    func setSelectedOption() {
        switch selectedDateFormatOption {
        case dateFormatTableOptions[0]:
            selectedDateFormatIndex = 0
        case dateFormatTableOptions[1]:
            selectedDateFormatIndex = 1
        case dateFormatTableOptions[2]:
            selectedDateFormatIndex = 2
        case dateFormatTableOptions[3]:
            selectedDateFormatIndex = 3
        case dateFormatTableOptions[4]:
            selectedDateFormatIndex = 4
        case dateFormatTableOptions[5]:
            selectedDateFormatIndex = 5
        case dateFormatTableOptions[6]:
            selectedDateFormatIndex = 6
        case dateFormatTableOptions[7]:
            selectedDateFormatIndex = 7
        case dateFormatTableOptions[8]:
            selectedDateFormatIndex = 8
        case dateFormatTableOptions[9]:
            selectedDateFormatIndex = 9
        case dateFormatTableOptions[9]:
            selectedDateFormatIndex = 9
        default:
            selectedDateFormatIndex = 0
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateFormatTableOptions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure a date format cell
        let dateFormatCell = tableView.dequeueReusableCell(withIdentifier: CELL_DATE_FORMAT, for: indexPath)
        var content = dateFormatCell.defaultContentConfiguration()
        
        // Display each available date format with an example
        let dateFormat = dateFormatTableOptions[indexPath.row]
        content.text = dateFormat
        content.secondaryText = "eg. " + getDateFormatExample(dateFormat: dateFormat)
        
        // Only add checkmark to the selected preferred date format
        if(indexPath.row == selectedDateFormatIndex) {
            dateFormatCell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            dateFormatCell.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        dateFormatCell.contentConfiguration = content
        return dateFormatCell
    }
    
    // Get a date example with the specified date format
    func getDateFormatExample(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: Date())
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Update selectedDateFormatIndex and checkmark based on selected preferred date format
        selectedDateFormatIndex = indexPath.row
        tableView.reloadData()
        
        // Update preferred date format
        updateDateFormat(dateFormat: dateFormatTableOptions[selectedDateFormatIndex ?? 0])
        
        // Inform the settings page of the newly selected preferred date format and navigate back
        selectDateFormatDelegate?.selectedDateFormatOption = dateFormatTableOptions[selectedDateFormatIndex ?? 0]
        navigationController?.popViewController(animated: true)
    }
    
    // Update preferred date format in user defaults
    func updateDateFormat(dateFormat: String) {
        UserDefaults.standard.set(dateFormat, forKey: "dateFormat")
    }
    
}
