//
//  AddNewFoodItemViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 26/4/2023.
//

import UIKit
import UserNotifications

class AddNewFoodItemViewController: UIViewController, UITextFieldDelegate, SelectExpiryAlertDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var expiryAlertTextField: UITextField!
    @IBOutlet weak var expiryAlertTimeLabel: UILabel!
    @IBOutlet weak var expiryAlertTimeTextField: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    
    var selectedExpiryAlertOption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Set up date picker for expiry date field
        expiryDateTextField.delegate = self
        showExpiryDatePicker()
        
        // Set up expiry alert field
        expiryAlertTextField.delegate = self
        
        // Set up time picker for expiry alert time field
        expiryAlertTimeTextField.delegate = self
        expiryAlertTimeTextField.text = "09:00 am"
        showExpiryAlertTimePicker()
        
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
    
    func showExpiryAlertTimePicker() {
        let toolbar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 45))
        
        // Set up done button for closing time picker
        let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneButtonClicked))
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        
        // Set up time picker
        let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 300))
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(timeChange(timePicker:)), for: UIControl.Event.valueChanged)
        
        // Preset default time (9am) for alert
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let date = dateFormatter.date(from: "09:00 am")
        datePicker.date = date ?? Date()
        
        // Attach date picker to expiry alert time field
        expiryAlertTimeTextField.inputAccessoryView = toolbar
        expiryAlertTimeTextField.inputView = datePicker
    }
    
    // Update expiry alert time field if time picker time changed
    @objc func timeChange(timePicker: UIDatePicker) {
        expiryAlertTimeTextField.text = formatTime(date: timePicker.date)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Perform showExpiryAlertSegue if expiry alert field selected
        if textField == expiryAlertTextField {
            performSegue(withIdentifier: "showExpiryAlertSegue", sender: nil)
            expiryAlertTextField.isEnabled = false
        }
    }
    
    @IBAction func addItem(_ sender: Any) {
        guard var name = nameTextField.text, let expiryDate = expiryDateTextField.text, let alert = expiryAlertTextField.text else {
            return
        }
        
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate name and expiry date fields
        if name.isEmpty || expiryDate.isEmpty {
            var errorMsg = "Please ensure all fields are filled:"
            if name.isEmpty {
                errorMsg += "\n- Must provide a name"
            }
            if expiryDate.isEmpty {
                errorMsg += "\n- Must provide an expiry date"
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
        
        // Add food to database
        let food = databaseController?.addFood(name: name, expiryDate: date, alert: alert)
        
        // Schedule local notification
        if alert != expiryAlertOptions.none.rawValue {
            let id = food?.id ?? "NA"
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
 References
 - Showing date picker for expiry date text field: https://stackoverflow.com/questions/54663063/uidatepicker-as-a-inputview-to-uitextfield
 */
