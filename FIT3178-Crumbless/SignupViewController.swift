//
//  SignupViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 17/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class SignupViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()}
    
    @IBAction func signupBtnClicked (_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        if !isValidEmail(email: email) || !isValidPassword(password: password) {
            var errorMsg = "Please ensure all fields are valid:\n"
            if email.isEmpty {
                errorMsg += "- Must enter a valid email\n"
            }
            if password.isEmpty {
                errorMsg += "- Password must be 6 characters long or more"
            }
            displayMessage(title: "Invalid account details", message: errorMsg)
            return
        }
        
        let signupSuccessfully = signup(email: email, password: password)
        
        print("before: \(signupSuccessfully)")
        if signupSuccessfully {
            print("after: \(signupSuccessfully)")
            navigationController?.popViewController(animated: true)
        }
    }
    
    func signup(email: String, password: String) -> Bool {
        var signupSuccessfully = false
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as? NSError {
                var errorMsg = "Unable to login"
                switch AuthErrorCode.Code(rawValue: (error.code)) {
                case .emailAlreadyInUse:
                    // The email address is already in use by another account
                    errorMsg = "The email address is already in use by another account"
                case .invalidEmail:
                    // The email address is badly formatted
                    errorMsg = "The email address is invalid"
                case .weakPassword:
                    // The password must be 6 characters long or more.
                    errorMsg = "The password must be 6 characters long or more"
                default:
                    errorMsg = "\(error.localizedDescription)"
                }
                self.displayMessage(title: "Signup Failed", message: errorMsg)
            } else {
                let newUserInfo = Auth.auth().currentUser
                let email = newUserInfo?.email
                print("User (\(email!)) signs up successfully")
                signupSuccessfully = true
            }
        }
        
        return signupSuccessfully
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
