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
        
        // Disable large navigation bar title
        navigationItem.largeTitleDisplayMode = .never
        
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Set up date picker for expiry date field
        expiryDateTextField.delegate = self
        setUpExpiryDatePicker(expiryDateTextField: expiryDateTextField, expiryDate: Date())
        
        // Set up expiry alert field
        expiryAlertTextField.delegate = self
        expiryAlertTextField.rightViewMode = .always
        let stackView = UIStackView()
        stackView.addArrangedSubview(UIImageView(image: UIImage(systemName: "chevron.right")))
        expiryAlertTextField.rightView = stackView
        
        // Set up time picker for expiry alert time field
        expiryAlertTimeTextField.delegate = self
        expiryAlertTimeTextField.text = "09:00 am"
        setUpExpiryAlertTimePicker(expiryAlertTimeTextField: expiryAlertTimeTextField, alertTime: "09:00 am")
        
        // Request permission for local notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, error) in
            if !granted {
                print("Permission was not granted!")
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Update the expiry alert field
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
        // Navigate to the expiry alert page if expiry alert field selected
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
        let date = stringToDate(dateString: expiryDate)
        
        // Validate expiry alert
        let alertTime = expiryAlertTimeTextField.text ?? "09:00 am"
        if alert != expiryAlertOptions.none.rawValue && !validateAlert(expiry: date, alert: alert, alertTime: alertTime) {
            displayMessage(title: "Invalid Alert", message: "Please set an alert after the current time")
            return
        }
        
        // Add food to database
        let food = databaseController?.addFood(name: name, expiryDate: date, alert: alert, alertTime: alertTime)
        
        // Schedule local notification for expiry alert
        if alert != expiryAlertOptions.none.rawValue {
            let id = food?.id ?? "NA"
            scheduleAlert(id: id, name: name, alert: alert, alertTime: alertTime, expiryDate: date)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Set the previously selected expiry alert option before navigating to the expiry alert page
        if segue.identifier == "showExpiryAlertSegue" {
            let destination = segue.destination as! ExpiryAlertTableViewController
            destination.selectExpiryAlertDelegate = self
            destination.selectedExpiryAlertOption = expiryAlertTextField.text
        }
    }
    
}


/**
 References
 - Adding chevron at the end of expiry alert text field: https://stackoverflow.com/questions/27903500/swift-add-icon-image-in-uitextfield
 */
