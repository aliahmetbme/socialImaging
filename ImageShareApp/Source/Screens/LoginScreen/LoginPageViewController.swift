//
//  ViewController.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 23.06.2024.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginPageViewController: UIViewController {
    
    @IBOutlet var serverError: UILabel!
    @IBOutlet var incorrectpassword: UILabel!
    @IBOutlet var incorrectemail: UILabel!
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwprdTextfield: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        initialDesign()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initialDesign()
    }
    
    func initialDesign () {
        emailTextfield.initialTextFieldDesign(cornerRadius:25)
        passwprdTextfield.initialTextFieldDesign(cornerRadius:25)
        loginButton.initialButtonDesign()
        
        incorrectemail.isHidden = true
        incorrectpassword.isHidden = true
    }
}

// Actions
extension LoginPageViewController {
    
    @IBAction func register(_ sender: Any) {
        performSegue(withIdentifier: "goRegistrationVC", sender: nil)

    }
    
    @IBAction func logIn(_ sender: Any) {
        initialDesign()
        
        if emailTextfield.text == "" || passwprdTextfield.text == "" {
            
            showNullError(input: emailTextfield, message: incorrectemail)
            showNullError(input: passwprdTextfield, message: incorrectpassword)
            
        } else {
        
            Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwprdTextfield.text!, completion: { AuthDataResult, Error in
                if Error != nil {
                    let ErrorMessage = Error!.localizedDescription
                    
                    if (ErrorMessage == AuthError.invalidEmail.rawValue) {
                        self.showError(input: self.emailTextfield, messageLabel: self.incorrectemail, message: ErrorMessage)
                    } else if (ErrorMessage == AuthError.invalidPassword.rawValue) {
                        self.showError(input: self.passwprdTextfield, messageLabel: self.incorrectpassword, message: ErrorMessage)
                    } else {
                        self.showError(input: self.emailTextfield, messageLabel: self.incorrectemail, message: ErrorMessage)
                        self.showError(input: self.passwprdTextfield, messageLabel: self.incorrectpassword, message: ErrorMessage)
                    }
                } else {
                    self.performSegue(withIdentifier: "toFeedVc", sender: nil)
                }
            })
            // async sunucuya yolla kullanıcı oluşturur ya da hata döner vb. cevabın ne zaman geleceği belli değil
            // bu arada kullanıcı işlemlerine devam edebilmesi için async çalışır
        }
    }
    
    @IBAction func googleSignIn(_ sender: Any) {
        signInGoogle { result in
            if (result) {
                // kullanıcı giriş yapmayı başarmışsa gerçek bir mail adresi vardır
                if let uid = Auth.auth().currentUser?.uid , let email = Auth.auth().currentUser?.email {
                    Firestore.firestore().collection("User").document(uid).setData(["userName": email.components(separatedBy: "@").first! ])
                    { error
                        in if error != nil {
                            print(error?.localizedDescription as Any)
                            self.emailTextfield.showErrorMessage(messageLabel: self.incorrectemail, message: error!.localizedDescription)
                            self.passwprdTextfield.showErrorMessage(messageLabel: self.incorrectpassword, message: error!.localizedDescription)
                        } else {
                            self.performSegue(withIdentifier: "toFeedVc", sender: nil)
                        }
                    }
                }
            }
        }
    }
    
}
