//
//  SignInViewController.swift
//  JournalCK27
//
//  Created by RYAN GREENBURG on 7/9/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        UserController.shared.fetchUser { (success) in
            if success {
                self.presentJournalView()
            }
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text, !username.isEmpty,
            let email = emailTextField.text, !email.isEmpty
            else { return }
        
        UserController.shared.createUser(withName: username, email: email) { (success) in
            if success {
                self.presentJournalView()
            }
        }
    }
    
    func presentJournalView() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let journalViewController = storyboard.instantiateViewController(withIdentifier: "JournalVC")
            self.present(journalViewController, animated: true)
        }
    }
}
