//
//  AddNewFoodItemViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 26/4/2023.
//

import UIKit

class AddNewFoodItemViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var expiryAlertTextField: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showExpiryDatePicker()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
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
        
        expiryAlertTextField.inputAccessoryView = toolbar
        expiryDateTextField.inputView = datePicker
    }

    @objc func dateChange(datePicker: UIDatePicker) {
        expiryDateTextField.text = formatDate(date: datePicker.date)
    }
    
    @objc func doneButtonClicked() {
        view.endEditing(true)
    }
    
    @IBAction func addItem(_ sender: Any) {
        guard var name = nameTextField.text, let expiryDate = expiryDateTextField.text, let alert = expiryAlertTextField.text else {
            return
        }
        
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if name.isEmpty || expiryDate.isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            if name.isEmpty {
                errorMsg += "- Must provide a name\n"
            }
            if expiryDate.isEmpty {
                errorMsg += "- Must provide an expiry date"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let date = dateFormatter.date(from: expiryDate)!
        
        let _ = databaseController?.addFood(name: name, expiryDate: date, alert: alert)
        
        navigationController?.popViewController(animated: true)
    }
    
}
