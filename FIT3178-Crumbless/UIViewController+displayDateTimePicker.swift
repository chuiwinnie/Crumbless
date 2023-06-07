//
//  UIViewController+displayDateTimePicker.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 7/6/2023.
//

import Foundation
import UIKit

extension UIViewController {
    class CustomDatePicker: UIDatePicker {
        // The text field that the custom date/time picker is attached to
        var textField: UITextField?
    }
    
    // Set up date picker for expiry date text field
    func showExpiryDatePicker(expiryDateTextField: UITextField, expiryDate: Date) {
        let toolbar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 45))
        
        // Set up done button for closing date picker
        let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneButtonClicked))
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        
        // Set up date picker
        let datePicker = CustomDatePicker.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 300))
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.textField = expiryDateTextField
        datePicker.addTarget(self, action: #selector(dateChange(datePicker: )), for: UIControl.Event.valueChanged)
        
        // Set minimum date and default/previously selected date for expiry
        datePicker.minimumDate = Date()
        datePicker.date = expiryDate
        
        // Attach date picker to expiry date field
        expiryDateTextField.inputAccessoryView = toolbar
        expiryDateTextField.inputView = datePicker
    }
    
    // Close text field date/time picker
    @objc func doneButtonClicked() {
        view.endEditing(true)
    }
    
    // Update expiry date field if date picker date changed
    @objc func dateChange(datePicker: CustomDatePicker) {
        datePicker.textField?.text = dateToString(date: datePicker.date)
    }
    
    // Set up time picker for expiry alert time text field
    func showExpiryAlertTimePicker(expiryAlertTimeTextField: UITextField, alertTime: String) {
        let toolbar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 45))
        
        // Set up done button for closing time picker
        let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneButtonClicked))
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        
        // Set up time picker
        let timePicker = CustomDatePicker.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 300))
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.textField = expiryAlertTimeTextField
        timePicker.addTarget(self, action: #selector(timeChange(timePicker: )), for: UIControl.Event.valueChanged)
        
        // Set default/previously selected time for alert
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        let time = timeFormatter.date(from: alertTime)
        timePicker.date = time ?? Date()
        
        // Attach time picker to expiry alert time field
        expiryAlertTimeTextField.inputAccessoryView = toolbar
        expiryAlertTimeTextField.inputView = timePicker
    }
    
    // Update expiry alert time field if time picker time changed
    @objc func timeChange(timePicker: CustomDatePicker) {
        timePicker.textField?.text = timeToString(date: timePicker.date)
    }
    
}


/**
 References
 - Creating custom date picker class: https://stackoverflow.com/questions/33498064/pass-multiple-parameters-to-addtarget/39584022#39584022
 - Setting default date time: https://stackoverflow.com/questions/33405710/how-to-set-a-specific-default-time-for-a-date-picker-in-swift
 - Showing date picker for expiry date text field: https://stackoverflow.com/questions/54663063/uidatepicker-as-a-inputview-to-uitextfield
 */
