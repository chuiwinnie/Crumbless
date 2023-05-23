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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func signUp (_ sender: Any) {
        guard var name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let confirmedPassword = confirmPasswordTextField.text else {
            return
        }
        
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if name.isEmpty || !isValidEmail(email: email) || !isValidPassword(password: password) || confirmedPassword.isEmpty || !passwordConfirmed(password: password, confirmedPassword: confirmedPassword) {
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
                errorMsg += "\n- Must confirm password"
            } else if !passwordConfirmed(password: password, confirmedPassword: confirmedPassword) {
                errorMsg += "\n- Password does not match"
            }
            displayMessage(title: "Invalid Account Details", message: errorMsg)
            return
        }
        
        databaseController?.signUp(name: name, email: email, password: password) { (signUpSuccess, error) in
            DispatchQueue.main.async {
                if signUpSuccess {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                self.displayMessage(title: "Sign Up Failed", message: error)
            }
        }
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(password: String) -> Bool {
        let minPasswordLength = 6
        return password.count >= minPasswordLength
    }
    
    func passwordConfirmed (password: String, confirmedPassword: String) -> Bool {
        return password == confirmedPassword
    }
}
