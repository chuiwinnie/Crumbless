//
//  LoginViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 17/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable large navigation bar title
        navigationItem.largeTitleDisplayMode = .never
        
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Set up indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    @IBAction func login(_ sender: Any) {
        guard var email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate email and password fields
        if email.isEmpty || password.isEmpty {
            var errorMsg = "Please ensure all fields are filled:"
            if email.isEmpty {
                errorMsg += "\n- Must enter an email"
            }
            if password.isEmpty {
                errorMsg += "\n- Must enter a password"
            }
            displayMessage(title: "Invalid Account Details", message: errorMsg)
            return
        }
        
        // Start animating indicator
        indicator.startAnimating()
        
        // Login
        databaseController?.login(email: email, password: password) { (loginSuccess, error) in
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                
                if loginSuccess {
                    // Remove all expiry alerts for previous anonymous user
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    
                    // Schedule expiry alert for all food items for logged in user
                    let foodList = self.databaseController?.getFoodList()
                    for food in foodList ?? [] {
                        let alert = food.alert
                        if alert != nil && alert != expiryAlertOptions.none.rawValue {
                            self.scheduleAlert(id: food.id!, name: food.name!, alert: food.alert!, alertTime: food.alertTime!, expiryDate: food.expiryDate!)
                        }
                    }
                    
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                // Display error message if login failed
                self.displayMessage(title: "Login Failed", message: error)
            }
        }
    }
    
}


/**
 References
 - Using returned values from async login function: https://stackoverflow.com/questions/52287840/how-i-can-return-value-from-async-block-in-swift
 */
