//
//  Extension+UIViewController.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 14.07.2024.
//

import Foundation
import UIKit

extension UIViewController {
    func passwordMatchCheck(password: UITextField, rePassword: UITextField) -> Bool {
        if (password.text == "" || rePassword.text == "") {return false}
        return (password.text == rePassword.text)
    }
    
    func showNullError(input: UITextField, message: UILabel) {
        if (input.text == ""){
            message.text = "It cannot be empty"
            message.isHidden = false
            message.textColor = UIColor.red
            
            input.layer.borderWidth = 1
            input.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    func showFuncMatchError(password: UITextField, rePassword: UITextField, message: String, passwordMessageLabel: UILabel, repasswordMessageLabel: UILabel) {
        password.showErrorMessage(messageLabel: passwordMessageLabel, message: message)
        rePassword.showErrorMessage(messageLabel: repasswordMessageLabel, message: message)
    }
    
    func showError(input: UITextField, messageLabel: UILabel = UILabel() , message: String = "") {
        
        input.layer.borderColor = UIColor.red.cgColor
        input.layer.borderWidth = 1
        messageLabel.isHidden = false
        messageLabel.text = message
    }
}
