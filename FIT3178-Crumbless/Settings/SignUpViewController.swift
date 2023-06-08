//
//  SignupViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 17/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class SignUpViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
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
    
    @IBAction func signUp (_ sender: Any) {
        guard var name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let confirmedPassword = confirmPasswordTextField.text else {
            return
        }
        
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate username, email, password and confirm password fields
        if name.isEmpty || !isValidEmail(email: email) || !isValidPassword(password: password) || !passwordConfirmed(password: password, confirmedPassword: confirmedPassword) {
            var errorMsg = "Please ensure all fields are valid:"
            if name.isEmpty {
                errorMsg += "\n- Must enter a name"
            }
            if !isValidEmail(email: email) {
                errorMsg += "\n- Must enter a valid email"
            }
            if !isValidPassword(password: password) {
                errorMsg += "\n- Password must be 6 characters long or more"
            }
            if confirmedPassword.isEmpty {
                errorMsg += "\n- Please confirm password"
            } else if !passwordConfirmed(password: password, confirmedPassword: confirmedPassword) {
                errorMsg += "\n- Password does not match"
            }
            displayMessage(title: "Invalid Account Details", message: errorMsg)
            return
        }
        
        // Start animating indicator
        indicator.startAnimating()
        
        databaseController?.signUp(name: name, email: email, password: password) { (signUpSuccess, error) in
            DispatchQueue.main.async {
                if signUpSuccess {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                self.indicator.stopAnimating()
                self.displayMessage(title: "Sign Up Failed", message: error)
            }
        }
    }
    
    // Validate email
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Validate password
    func isValidPassword(password: String) -> Bool {
        let minPasswordLength = 6
        return password.count >= minPasswordLength
    }
    
    // Check if password is confirmed
    func passwordConfirmed (password: String, confirmedPassword: String) -> Bool {
        return password == confirmedPassword
    }
    
}
