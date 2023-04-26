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

    override func viewDidLoad() {
        super.viewDidLoad()
        showExpiryDatePicker()
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
