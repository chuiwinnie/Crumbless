//
//  FoodDetailsViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 3/5/2023.
//

import UIKit

class FoodDetailsViewController: UIViewController, UITextFieldDelegate, SelectExpiryAlertDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var expiryAlertTextField: UITextField!
    @IBOutlet weak var expiryAlertTimeLabel: UILabel!
    @IBOutlet weak var expiryAlertTimeTextField: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    
    var food: Food!
    
    var selectedExpiryAlertOption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Set food item details
        nameTextField.text = food.name
        expiryDateTextField.text = dateToString(date: food.expiryDate ?? Date())
        selectedExpiryAlertOption = food.alert
        
        // Set up date picker for expiry date field
        expiryDateTextField.delegate = self
        showExpiryDatePicker(expiryDateTextField: expiryDateTextField, expiryDate: food.expiryDate ?? Date())
        
        // Set up expiry alert field
        expiryAlertTextField.delegate = self
        
        // Set up time picker for expiry alert time field
        expiryAlertTimeTextField.delegate = self
        expiryAlertTimeTextField.text = food.alertTime
        showExpiryAlertTimePicker(expiryAlertTimeTextField: expiryAlertTimeTextField, alertTime: food.alertTime ?? "09:00 am")
        
        // Request permission for local notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, error) in
            if !granted {
                print("Permission was not granted!")
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Update expiry alert field option if selected
        expiryAlertTextField.isEnabled = true
        if let option = selectedExpiryAlertOption {
            expiryAlertTextField.text = option
        } else {
            expiryAlertTextField.text = "None"
        }
        
        // Only show option to set expiry alert time if expiry alert selected
        if expiryAlertTextField.text == "None" {
            expiryAlertTimeLabel.isHidden = true
            expiryAlertTimeTextField.isHidden = true
        } else {
            expiryAlertTimeLabel.isHidden = false
            expiryAlertTimeTextField.isHidden = false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Perform showExpiryAlertSegue if expiry alert field selected
        if textField == expiryAlertTextField {
            performSegue(withIdentifier: "showExpiryAlertSegue", sender: nil)
            expiryAlertTextField.isEnabled = false
        }
    }
    
    @IBAction func updateItem(_ sender: Any) {
        guard var name = nameTextField.text, let expiryDate = expiryDateTextField.text, let alert = expiryAlertTextField.text else {
            return
        }
        
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate name and expiry date fields
        if name.isEmpty || expiryDate.isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            if name.isEmpty {
                errorMsg += "- Must provide a name\n"
            }
            if expiryDate.isEmpty {
                errorMsg += "- Must provide an expiry date"
            }
            displayMessage(title: "Invalid Food Details", message: errorMsg)
            return
        }
        
        // Convert expiry date field text to Date
        let date = stringToDate(dateString: expiryDate)
        
        // Validate expiry alert
        let alertTime = expiryAlertTimeTextField.text ?? "09:00 am"
        let validAlert = validateAlert(expiry: date, alert: alert, alertTime: alertTime)
        if !validAlert {
            displayMessage(title: "Invalid Alert", message: "Please set an alert in between the current time and the expiry date.")
            return
        }
        
        // Update food details in database
        food.name = name
        food.expiryDate = date
        food.alert = alert
        food.alertTime = alertTime
        databaseController?.updateFood(food: food)
        
        // Reschedule local notification
        let id = food?.id ?? "NA"
        cancelAlert(id: id)
        if alert != expiryAlertOptions.none.rawValue {
            scheduleAlert(id: id, name: name, alert: alert, alertTime: alertTime, expiryDate: date)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Preset to previously selected expiry alert option before showing the expiry alert table view
        if segue.identifier == "showExpiryAlertSegue" {
            let destination = segue.destination as! ExpiryAlertTableViewController
            destination.selectExpiryAlertDelegate = self
            destination.selectedExpiryAlertOption = expiryAlertTextField.text
        }
    }
    
}


/**
 References
 
 */
