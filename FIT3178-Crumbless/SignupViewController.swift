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
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { auth, user in
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func signUpBtnClicked (_ sender: Any) {
        guard var name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if name.isEmpty || !isValidEmail(email: email) || !isValidPassword(password: password) {
            var errorMsg = "Please ensure all fields are valid:\n"
            if name.isEmpty {
                errorMsg += "- Must enter a name\n"
            }
            if !isValidEmail(email: email) {
                errorMsg += "- Must enter a valid email\n"
            }
            if !isValidPassword(password: password) {
                errorMsg += "- Password must be 6 characters long or more"
            }
            displayMessage(title: "Invalid account details", message: errorMsg)
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
    
    
     // MARK: - Navigation
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     }
}
