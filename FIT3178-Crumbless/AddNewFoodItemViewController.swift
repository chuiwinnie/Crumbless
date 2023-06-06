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
    
    var expiryAlertOptions = ["None", "1 day before", "2 days before", "3 days before", "1 week before", "2 weeks before"]
    var selectedExpiryAlertOption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up date picker for expiry date field
        expiryDateTextField.delegate = self
        showExpiryDatePicker()
        
        // Set up expiry alert field
        expiryAlertTextField.delegate = self
        
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
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
    
    // Update expiry date field if date picker date changed
    @objc func dateChange(datePicker: UIDatePicker) {
        expiryDateTextField.text = formatDate(date: datePicker.date)
    }
    
    // Close expiry date field date picker
    @objc func doneButtonClicked() {
        view.endEditing(true)
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
        if !(alert == expiryAlertOptions[0]) {
            let id = food?.id ?? "NA"
            scheduleAlert(id: id, name: name, alert: alert, expiryDate: date)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // Check if the alert is set before the expiry date
    func validateAlert(expiryDate: Date, alert: String) -> Bool {
        let daysBeforeExpiry = getDaysBeforeExpiry(expiryDate: expiryDate)
        let daysBeforeAlert = daysBeforeExpiry - getAlertDaysBeforeExpiry(alert: alert)
        if daysBeforeAlert <= 0 {
            return false
        }
        return true
    }
    
    func scheduleAlert(id: String, name: String, alert: String, expiryDate: Date) {
        let timeRemaining = getTimeRemaining(alert: alert)
        
        // Configure notification content
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Food Expiry Alert"
        notificationContent.body = "\(name) is expiring in \(timeRemaining)!"
        
        // Calculate the date for alert
        let daysBeforeExpiry = getDaysBeforeExpiry(expiryDate: expiryDate)
        let daysBeforeAlert = daysBeforeExpiry - getAlertDaysBeforeExpiry(alert: alert)
        let alertDate = Calendar.current.date(byAdding: .day, value: daysBeforeAlert, to: Date()) ?? Date()
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: alertDate)
        dateComponents.hour = 4
        dateComponents.minute = 53
        print("Alert set for: \(dateComponents.year!)-\(dateComponents.month!)-\(dateComponents.day!) \(dateComponents.hour!):\(dateComponents.minute!)")
        
        // Schedule notification
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // Get the amount of time remaining before food expiry as a string
    func getTimeRemaining(alert: String) -> String {
        var timeRemaining: String
        switch alert {
        case expiryAlertOptions[1]:
            timeRemaining = "1 day"
        case expiryAlertOptions[2]:
            timeRemaining = "2 days"
        case expiryAlertOptions[3]:
            timeRemaining = "3 days"
        case expiryAlertOptions[4]:
            timeRemaining = "1 week"
        case expiryAlertOptions[5]:
            timeRemaining = "2 weeks"
        default:
            timeRemaining = "NA"
        }
        return timeRemaining
    }
    
    // Get the number of days remaining before food expiry
    func getDaysBeforeExpiry(expiryDate: Date) -> Int{
        let daysBeforeExpiry = (Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0) + 1
        return daysBeforeExpiry
    }
    
    // Get the number of days between the alert date and expiry date
    func getAlertDaysBeforeExpiry(alert: String) -> Int {
        var daysBeforeExpiry: Int
        switch alert {
        case expiryAlertOptions[1]:
            daysBeforeExpiry = 1
        case expiryAlertOptions[2]:
            daysBeforeExpiry = 2
        case expiryAlertOptions[3]:
            daysBeforeExpiry = 3
        case expiryAlertOptions[4]:
            daysBeforeExpiry = 7
        case expiryAlertOptions[5]:
            daysBeforeExpiry = 14
        default:
            daysBeforeExpiry = 0
        }
        return daysBeforeExpiry
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
 - Scheduling local notification: https://www.hackingwithswift.com/books/ios-swiftui/scheduling-local-notifications
 - Scheduling local notification on a specific date: https://stackoverflow.com/questions/44632876/swift-3-how-to-set-up-local-notification-at-specific-date
 - Scheduling local notification at a specific time: https://stackoverflow.com/questions/52009454/how-do-i-send-local-notifications-at-a-specific-time-in-swift
 - Calculating date from now: https://www.appsdeveloperblog.com/add-days-months-or-years-to-current-date-in-swift/
 - Calculating difference between 2 dates: https://iostutorialjunction.com/2019/09/get-number-of-days-between-two-dates-swift.html
 - Converting Date to DateComponents: https://stackoverflow.com/questions/42042215/convert-date-to-datecomponents-in-function-to-schedule-local-notification-in-swi
 */
