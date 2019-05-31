//
//  LogInViewController.swift
//  tinder
//
//  Created by Mahieu Bayon on 25/09/2018.
//  Copyright © 2018 M4m0ut. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInSignUpButton: UIButton!
    @IBOutlet weak var changeLogInSignUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var signUpMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        errorLabel.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if PFUser.current() != nil {
            
            if PFUser.current()?["isFemale"] != nil {
                self.performSegue(withIdentifier: "loginToSwipeSegue", sender: nil)

            } else {
               self.performSegue(withIdentifier: "signupToUpdateSegue", sender: nil)
            }
        }
    }
    
    @IBAction func logInSignUpTapped(_ sender: Any) {
        
        if signUpMode {
            
            let user = PFUser()
            
            user.username = usernameTextField.text
            user.password = passwordTextField.text
            
            user.signUpInBackground(block: { (success, error) in
                
                if error != nil {
                    
                    var errorMessage = "Sign Up failed - Try Again"
                    
                    if let error = error as NSError? {
                        
                        if let detailError = error.userInfo["error"] as? String {
                            errorMessage = detailError
                        }
                    }
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = errorMessage
                    
                } else {
                    self.performSegue(withIdentifier: "signupToUpdateSegue", sender: nil)
                }
            })
        } else {
            
            if let username = usernameTextField.text {
                if let password = passwordTextField.text {
                    
                    PFUser.logInWithUsername(inBackground: username, password: password, block: { (user, error) in
                        
                        if error != nil {
                            
                            var errorMessage = "Login failed - Try Again"
                            
                            if let error = error as NSError? {
                                
                                if let detailError = error.userInfo["error"] as? String {
                                    errorMessage = detailError
                                }
                            }
                            self.errorLabel.isHidden = false
                            self.errorLabel.text = errorMessage
                            
                        } else {
                            if user?["isFemale"] != nil {
                                self.performSegue(withIdentifier: "loginToSwipeSegue", sender: nil)
                                
                            } else {
                                self.performSegue(withIdentifier: "signupToUpdateSegue", sender: nil)
                            }
                         }
                    })

                }
            }
        }
    }

    @IBAction func changeLogInSignUpTapped(_ sender: Any) {
        
        if signUpMode {
            logInSignUpButton.setTitle("Log In", for: .normal)
            changeLogInSignUpButton.setTitle("Sign Up ", for: .normal)
            signUpMode = false
        } else {
            logInSignUpButton.setTitle("Sign Up", for: .normal)
            changeLogInSignUpButton.setTitle("Log In", for: .normal)
            signUpMode = true
        }
    } 
}
