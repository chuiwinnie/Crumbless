//
//  AccountViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 17/5/2023.
//

import UIKit

class AccountViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        textView.isEditable = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Show either user account details or login/signup options based on login status
        if databaseController?.userSignedIn ?? false {
            setAccountDetailsTextView()
            loginButton.isHidden = true
            signUpLabel.isHidden = true
            signUpButton.isHidden = true
            signOutButton.isHidden = false
        } else {
            loginButton.isHidden = false
            signUpLabel.isHidden = false
            signUpButton.isHidden = false
            signOutButton.isHidden = true
        }
    }
    
    @IBAction func signOut(_ sender: Any) {
        databaseController?.signOut() { (signOutSuccess, error) in
            DispatchQueue.main.async {
                if signOutSuccess {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                self.displayMessage(title: "Sign Out Failed", message: error)
            }
        }
    }
    
    func setAccountDetailsTextView() {
        // Set paragraph style
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        style.alignment = .left
        
        // Create name and email labels
        let boldAttributes = [NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)]
        let nameTitle = NSMutableAttributedString(string: "Name:\n", attributes: boldAttributes)
        let emailTitle = NSMutableAttributedString(string: "\n\nEmail:\n", attributes: boldAttributes)
        
        // Create name and email details
        let normalAttributes = [NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)]
        let nameText = NSMutableAttributedString(string: "\(databaseController?.user?.name ?? "NA")", attributes: normalAttributes)
        let emailText = NSMutableAttributedString(string: "\(databaseController?.user?.email! ?? "NA")", attributes: normalAttributes)
        
        // Append all labels and details to the text view
        nameTitle.append(nameText)
        nameTitle.append(emailTitle)
        nameTitle.append(emailText)
        textView.attributedText = nameTitle
        
        // Change text to white if in dark mode
        if (UserDefaults.standard.bool(forKey: "darkMode")) {
            textView.textColor = .white
        }
    }
    
}
