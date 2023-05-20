//
//  FoodDetailsViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 3/5/2023.
//

import UIKit

class FoodDetailsViewController: UIViewController {
    var food: Food!
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var expiryAlertTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set food item details
        nameTextField.text = food.name
        expiryDateTextField.text = formatDate(date: food.expiryDate ?? Date())
        expiryAlertTextField.text = food.alert
        
        // Show date picker for expiry date field
        showExpiryDatePicker()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    func showExpiryDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.minimumDate = Date()
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        
        expiryDateTextField.inputView = datePicker
    }
    
    @objc func dateChange(datePicker: UIDatePicker) {
        expiryDateTextField.text = formatDate(date: datePicker.date)
    }
    
    @IBAction func updateItem(_ sender: Any) {
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
        
        food.name = name
        food.expiryDate = date
        food.alert = alert
        databaseController?.updateFood(food: food)
        
        navigationController?.popViewController(animated: true)
    }
    
}
