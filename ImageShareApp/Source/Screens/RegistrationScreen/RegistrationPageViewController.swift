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
    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var userNameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var rePasswordTextField: UITextField!
    @IBOutlet private var registerButton: UIButton!
    
    @IBOutlet private var emailErrorMessageLabel: UILabel!
    @IBOutlet private var nameErrorLabel: UILabel!
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var passwordErrorLabel: UILabel!
    @IBOutlet private var repasswordErrorLabel: UILabel!
    let firebaseAuthService = FireBaseAuthService()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        initialDesign()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        initialDesign()
    }
    
    private func initialDesign() {
        emailTextField.initialTextFieldDesign(cornerRadius:25)
        userNameTextField.initialTextFieldDesign(cornerRadius:25)
        nameTextField.initialTextFieldDesign(cornerRadius:25)
        passwordTextField.initialTextFieldDesign(cornerRadius:25)
        rePasswordTextField.initialTextFieldDesign(cornerRadius:25)
        
        emailErrorMessageLabel.isHidden = true
        nameErrorLabel.isHidden = true
        userNameLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        repasswordErrorLabel.isHidden = true
        
        registerButton.initialButtonDesign()
    }
    

}
// Actions
extension RegistrationPageViewController {
    
    @IBAction private  func goBackLoginPage(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private  func register(_ sender: Any) {
        initialDesign()
        // null check
        if  (emailTextField.text != "" && userNameTextField.text != "" && nameTextField.text  != "")  {
            // password match check
            if (passwordMatchCheck(password: passwordTextField, rePassword: rePasswordTextField)) {
                Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authDataResult, error in
                    if (error != nil) {
                        let errorMessage = error!.localizedDescription
                        // email errors
                        if (errorMessage == AuthError.emailAlreadyInUse.rawValue || errorMessage == AuthError.invalidEmail.rawValue)
                        {
                            self.showError(input: self.emailTextField, messageLabel: self.emailErrorMessageLabel, message: error!.localizedDescription)
                        // password error
                        } else if (errorMessage == AuthError.invalidPassword.rawValue) {
                            self.showError(input: self.passwordTextField, messageLabel: self.passwordErrorLabel, message: error!.localizedDescription)
                            self.showError(input: self.rePasswordTextField, messageLabel: self.repasswordErrorLabel, message: error!.localizedDescription)
                        // other error 
                        } else {
                            self.showError(input: self.emailTextField)
                            self.showError(input: self.nameTextField)
                            self.showError(input: self.userNameTextField)
                            self.showError(input: self.passwordTextField)
                            self.showError(input: self.rePasswordTextField, messageLabel: self.repasswordErrorLabel, message: error!.localizedDescription)
                        }
                        
                    } else {
                        // setting Name
                        self.firebaseAuthService.updateDisplayName(newDisplayName: self.nameTextField.text!)
                        
                        // setting username via path users uid
                        if let uid = authDataResult?.user.uid  {
                            Firestore.firestore().collection(DBEndPoints.User.endPointsString).document(uid).setData([DBEndPoints.userName.endPointsString :self.userNameTextField.text!]) {
                                error in if error != nil {
                                    self.showError(input: self.emailTextField)
                                    self.showError(input: self.nameTextField)
                                    self.showError(input: self.userNameTextField)
                                    self.showError(input: self.passwordTextField)
                                    self.showError(input: self.rePasswordTextField, messageLabel: self.repasswordErrorLabel, message: error!.localizedDescription)
                                }
                            }
                        }
                        
                      self.performSegue(withIdentifier: "RegtoFeedVC", sender: nil)
                    }
                }
            } else {
                // if passwords does not much
                showFuncMatchError(password: passwordTextField, rePassword: rePasswordTextField, message: "Password must match", passwordMessageLabel: passwordErrorLabel, repasswordMessageLabel: repasswordErrorLabel)
            }
        } else {
            // if there is null input
            showNullError(input: emailTextField, message: emailErrorMessageLabel )
            showNullError(input: userNameTextField, message: userNameLabel)
            showNullError(input: nameTextField, message: nameErrorLabel)
            showNullError(input: passwordTextField, message: passwordErrorLabel)
            showNullError(input: rePasswordTextField, message: repasswordErrorLabel)
        }
    }
}
