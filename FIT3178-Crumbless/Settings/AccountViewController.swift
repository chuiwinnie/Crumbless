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
    
    override func viewWillAppear(_ animated: Bool) {
        if databaseController?.userSignedIn ?? false {
            // Display user account details and sign out option if logged in
            setAccountDetailsTextView()
            loginButton.isHidden = true
            signUpLabel.isHidden = true
            signUpButton.isHidden = true
            signOutButton.isHidden = false
        } else {
            // Show login and sign up options if not logged in
            loginButton.isHidden = false
            signUpLabel.isHidden = false
            signUpButton.isHidden = false
            signOutButton.isHidden = true
        }
    }
    
    // Display user account details
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
    
    @IBAction func signOut(_ sender: Any) {
        // Display message to confirm sign out
        let alertController = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        // Sign out confirmed
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            // Start animating indicator
            self.indicator.startAnimating()
            
            // Sign out
            self.databaseController?.signOut() { (signOutSuccess, error) in
                DispatchQueue.main.async {
                    if signOutSuccess {
                        // Remove all expiry alerts for signed out user
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                    self.indicator.stopAnimating()
                    self.displayMessage(title: "Sign Out Failed", message: error)
                }
            }
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
}


/**
 References
 - Sign out confirmation message: https://stackoverflow.com/questions/25511945/swift-alert-view-with-ok-and-cancel-which-button-tapped
 */
