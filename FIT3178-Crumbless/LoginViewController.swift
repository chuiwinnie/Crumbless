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
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        handle = Auth.auth().addStateDidChangeListener { auth, user in
        //        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func login(_ sender: Any) {
        guard var email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if email.isEmpty || password.isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            if email.isEmpty {
                errorMsg += "- Must enter an email\n"
            }
            if password.isEmpty {
                errorMsg += "- Must enter a password"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
        
        databaseController?.login(email: email, password: password) { (loginSuccess, error) in
            DispatchQueue.main.async {
                if loginSuccess {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                self.displayMessage(title: "Login Failed", message: error)
            }
        }
    }
}
