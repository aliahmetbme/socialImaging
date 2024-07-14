//
//  RegistrationPageViewController.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 14.07.2024.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class RegistrationPageViewController: UIViewController {

    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var rePasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.initialTextFieldDesign()
        userNameTextField.initialTextFieldDesign()
        passwordTextField.initialTextFieldDesign()
        rePasswordTextField.initialTextFieldDesign()

    }

    
}

// Actions
extension RegistrationPageViewController {
    
    @IBAction func goBackLoginPage(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func register(_ sender: Any) {
        
        // password check
        if  passwordMatchCheck(password: passwordTextField, rePassword: rePasswordTextField) {
            if (emailTextField.text != "" && userNameTextField.text != "") {
                Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authDataResult, error in
                    if (error != nil) {
                        print(error as Any)
                    } else {
                        
                        Firestore.firestore().collection("User").addDocument(data: ["userName":self.userNameTextField.text!]) {
                            error in if error != nil {
                                print(error?.localizedDescription)
                            }
                        }
                        
                        self.performSegue(withIdentifier: "RegtoFeedVC", sender: nil)
                    }
                }
            }
            
        } else {
        }
    }
}
