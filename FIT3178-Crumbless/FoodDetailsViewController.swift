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
        expiryDateTextField.text = formatDate(date: food.expiryDate ?? Date())
        selectedExpiryAlertOption = food.alert
        
        // Set up date picker for expiry date field
        expiryDateTextField.delegate = self
        showExpiryDatePicker()
        
        // Set up expiry alert field
        expiryAlertTextField.delegate = self
        
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
    }
    
    func showExpiryDatePicker() {
        let toolbar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 45))
        
        // Set up done button for closing date picker
        let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneButtonClicked))
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        
        // Set up date picker
        let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 300))
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.minimumDate = Date()
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        
        // Attach date picker to expiry date field
        expiryDateTextField.inputAccessoryView = toolbar
        expiryDateTextField.inputView = datePicker
    }
    
    // Close expiry date field date picker
    @objc func doneButtonClicked() {
        view.endEditing(true)
    }
    
    // Update expiry date field if date picker date changed
    @objc func dateChange(datePicker: UIDatePicker) {
        expiryDateTextField.text = formatDate(date: datePicker.date)
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let date = dateFormatter.date(from: expiryDate)!
        
        // Validate expiry alert
        let validAlert = validateAlert(expiryDate: date, alert: alert)
        if !validAlert {
            displayMessage(title: "Invalid Alert", message: "Please set an alert before the expiry date.")
            return
        }
        
        // Update food details in database
        food.name = name
        food.expiryDate = date
        food.alert = alert
        databaseController?.updateFood(food: food)
        
        // Reschedule local notification
        let id = food?.id ?? "NA"
        cancelAlert(id: id)
        if alert != expiryAlertOptions.none.rawValue {
            scheduleAlert(id: id, name: name, alert: alert, expiryDate: date)
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
 References:
 
 */
