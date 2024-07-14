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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        emailTextfield.initialTextFieldDesign()        
        passwprdTextfield.initialTextFieldDesign()

    }

    
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height / (self.view.frame.size.height * 0.01)
                
        UIView.animate(withDuration: 0.1) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            self.navigationController?.navigationBar.isHidden = true
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.1) {
            self.view.transform = .identity
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.endEditing(true)

    }
    
}

// Actions
extension LoginPageViewController {
    
    @IBAction func register(_ sender: Any) {
        performSegue(withIdentifier: "goRegistrationVC", sender: nil)

    }
    
    
    @IBAction func logIn(_ sender: Any) {
        
        serverError.isHidden = true
        incorrectemail.isHidden = true
        incorrectpassword.isHidden = true
        emailTextfield.layer.borderWidth = 0
        passwprdTextfield.layer.borderWidth = 0
        
        if emailTextfield.text == "" && passwprdTextfield.text == "" {
            emailTextfield.layer.borderColor = UIColor.red.cgColor
            emailTextfield.layer.borderWidth = 1
            
            passwprdTextfield.layer.borderColor = UIColor.red.cgColor
            passwprdTextfield.layer.borderWidth = 1
            
            incorrectemail.isHidden = false
            incorrectpassword.isHidden = false
            
            incorrectemail.text = "Please enter your email"
            incorrectpassword.text = "Please enter your password"

        } else if emailTextfield.text == "" {
            emailTextfield.layer.borderColor = UIColor.red.cgColor
            emailTextfield.layer.borderWidth = 1
            
            incorrectemail.isHidden = false

            incorrectemail.text = "Please enter your email"

        } else if passwprdTextfield.text == "" {
            passwprdTextfield.layer.borderColor = UIColor.red.cgColor
            passwprdTextfield.layer.borderWidth = 1
            
            incorrectpassword.isHidden = false
            
            incorrectpassword.text = "Please enter your password"

        } else {

            // kayıt için
            Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwprdTextfield.text!, completion: { AuthDataResult, Error in
                
                if Error != nil {
                    self.serverError.isHidden = false
                    self.serverError.text = Error?.localizedDescription
                    
                } else {
                    self.performSegue(withIdentifier: "toFeedVc", sender: nil)
                }

            })
            // async sunucuya yolla kullanıcı oluşturur ya da hata döner vb. cevabın ne zaman geleceği belli değil
            // bu arada kullanıcı işlemlerine devam edebilmesi için async çalışır
        }
    }
}


/*
 serverError.isHidden = true
 incorrectemail.isHidden = true
 incorrectpassword.isHidden = true
 emailTextfield.layer.borderWidth = 0
 passwprdTextfield.layer.borderWidth = 0
 
 if emailTextfield.text == "" && passwprdTextfield.text == "" {
     emailTextfield.layer.borderColor = UIColor.red.cgColor
     emailTextfield.layer.borderWidth = 1
     
     passwprdTextfield.layer.borderColor = UIColor.red.cgColor
     passwprdTextfield.layer.borderWidth = 1
     
     incorrectemail.isHidden = false
     incorrectpassword.isHidden = false
     
     incorrectemail.text = "Please enter your email"
     incorrectpassword.text = "Please enter your password"

 } else if emailTextfield.text == "" {
     emailTextfield.layer.borderColor = UIColor.red.cgColor
     emailTextfield.layer.borderWidth = 1
     
     incorrectemail.isHidden = false

     incorrectemail.text = "Please enter your email"

 } else if passwprdTextfield.text == "" {
     passwprdTextfield.layer.borderColor = UIColor.red.cgColor
     passwprdTextfield.layer.borderWidth = 1
     
     incorrectpassword.isHidden = false
     
     incorrectpassword.text = "Please enter your password"

 } else {

     // kayıt için
     Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwprdTextfield.text!) { AuthDataResult, Error in
         
         if Error != nil {
             self.serverError.isHidden = false
             self.serverError.text = Error?.localizedDescription
             
         } else {
             self.performSegue(withIdentifier: "toFeedVc", sender: nil)
         }

     }
     // async sunucuya yolla kullanıcı oluşturur ya da hata döner vb. cevabın ne zaman geleceği belli değil
     // bu arada kullanıcı işlemlerine devam edebilmesi için async çalışır
                 
 }

 */
