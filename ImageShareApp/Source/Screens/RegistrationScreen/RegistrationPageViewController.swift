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
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet private var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var rePasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.initialTextFieldDesign()
        userNameTextField.initialTextFieldDesign()
        nameTextField.initialTextFieldDesign()
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
        
        // null check
        if  (emailTextField.text != "" && userNameTextField.text != "" && nameTextField.text  != "")  {
            // password match check
            if (passwordMatchCheck(password: passwordTextField, rePassword: rePasswordTextField)) {
                Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authDataResult, error in
                    if (error != nil) {
                        print(error as Any)
                    } else {
                        
                        // setting Name
                        self.updateDisplayName(newDisplayName: self.nameTextField.text!)
                        
                        // setting username via path users uid
                        if let uid = authDataResult?.user.uid  {
                            Firestore.firestore().collection("User").document(uid).setData(["userName":self.userNameTextField.text!]) {
                                error in if error != nil {
                                    print(error?.localizedDescription as Any)
                                }
                            }
                        }
                      self.performSegue(withIdentifier: "RegtoFeedVC", sender: nil)
                    }
                }
            }
            
        } else {
            print("haatttaaa...")
        }
    }
}
