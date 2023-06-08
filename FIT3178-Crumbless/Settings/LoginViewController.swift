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
        
        databaseController?.login(email: email, password: password) { (loginSuccess, error) in
            DispatchQueue.main.async {
                if loginSuccess {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                self.indicator.stopAnimating()
                self.displayMessage(title: "Login Failed", message: error)
            }
        }
    }
    
}
