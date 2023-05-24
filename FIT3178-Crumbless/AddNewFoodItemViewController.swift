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
    
    weak var databaseController: DatabaseProtocol?
    
    var selectedExpiryAlertOption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showExpiryDatePicker()
        
        expiryAlertTextField.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, error) in
            if !granted {
                print("Permission was not granted!")
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        expiryAlertTextField.isEnabled = true
        if let option = selectedExpiryAlertOption {
            expiryAlertTextField.text = option
        } else {
            expiryAlertTextField.text = "None"
        }
    }
    
    func showExpiryDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonClicked))
        toolbar.setItems([doneButton], animated: true)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.minimumDate = Date()
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        
        expiryDateTextField.inputAccessoryView = toolbar
        expiryDateTextField.inputView = datePicker
    }
    
    @objc func dateChange(datePicker: UIDatePicker) {
        expiryDateTextField.text = formatDate(date: datePicker.date)
    }
    
    @objc func doneButtonClicked() {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == expiryAlertTextField {
            view.endEditing(true)
            performSegue(withIdentifier: "showExpiryAlertSegue", sender: nil)
            expiryAlertTextField.isEnabled = false
        }
    }
    
    @IBAction func addItem(_ sender: Any) {
        guard var name = nameTextField.text, let expiryDate = expiryDateTextField.text, let alert = expiryAlertTextField.text else {
            return
        }
        
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if name.isEmpty || expiryDate.isEmpty {
            var errorMsg = "Please ensure all fields are filled:"
            if name.isEmpty {
                errorMsg += "\n- Must provide a name\n"
            }
            if expiryDate.isEmpty {
                errorMsg += "\n- Must provide an expiry date"
            }
            displayMessage(title: "Invalid Food Details", message: errorMsg)
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let date = dateFormatter.date(from: expiryDate)!
        
        let _ = databaseController?.addFood(name: name, expiryDate: date, alert: alert)
        
        if !(alert == "None") {
            scheduleAlert(name: name, alert: alert)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func scheduleAlert(name: String, alert: String) {
        var timeRemaining: String
        switch alert {
        case "1 day before":
            timeRemaining = "1 day"
        case "2 days before":
            timeRemaining = "2 days"
        case "3 days before":
            timeRemaining = "3 days"
        case "1 week before":
            timeRemaining = "1 week"
        case "2 weeks before":
            timeRemaining = "2 weeks"
        default:
            timeRemaining = "NA"
        }
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Food Expiry Alert"
        notificationContent.body = "\(name) is expiring in \(timeRemaining)!"
        
        let timeInterval = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: timeInterval)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showExpiryAlertSegue" {
            let destination = segue.destination as! ExpiryAlertTableViewController
            destination.selectExpiryAlertDelegate = self
            destination.selectedExpiryAlert = expiryAlertTextField.text
        }
    }
    
}
